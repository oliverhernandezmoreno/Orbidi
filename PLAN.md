# Plan de ejecución y evolución — Orbidi

> Documento de trabajo. Resume el diagnóstico de `README.md`, `design.md`, `terraform/` y `.github/workflows/`, y define el orden de corrección.
>
> **Regla de oro:** no se avanza de fase sin `terraform fmt -check`, `terraform validate` y `terraform plan` en verde.

---

## 1. Diagnóstico general

La documentación describía una arquitectura razonable (VPC multi-AZ + ALB + Auto Scaling + ECR/ECS + S3/DynamoDB + CI/CD), pero **el código no coincidía con ella y, en el estado inicial, no era desplegable**:

- 4 fallos rompían `terraform validate/apply`.
- El pipeline ejecutaba Terraform en la raíz del repo, donde no hay archivos `.tf`.
- No existía entrega de la aplicación: las instancias del ASG arrancaban sin código.
- El estado era local, aunque la documentación afirmaba que era remoto.

Estado actual: **Fases 0 a 5 y 7 completadas**. La infraestructura valida, corre en ECS Fargate, usa OIDC, tiene observabilidad básica, tests de plan y documentación alineada.

---

## 2. Hallazgos

### P0 — Bloqueantes

| ID | Problema | Estado |
|---|---|---|
| E-01 | `profile = aws_default_security_group.default` (tipo inválido). | ✅ Fase 0 |
| E-02 | Outputs a `aws_s3_bucket.app_bucket` inexistente. | ✅ Fase 0 |
| E-03 | Tabla de app y de locks con el mismo nombre. | ✅ Fase 0 |
| E-04 | Terraform corría en la raíz del repo. | ✅ Fase 0 |
| E-05 | Variables obligatorias sin default. | ✅ Fase 0 |
| E-06 | Sin backend remoto. | ✅ Fase 1 |
| E-07 | ASG sin `user_data` (instancias sin aplicación). | ✅ Fase 2 |
| E-08 | `apps/` eran gitlinks vacíos sin `.gitmodules`. | ✅ Fase 2 (`app/`) |

### P1 — Altas

| ID | Problema | Estado |
|---|---|---|
| E-09 | AMI de 2023 / Amazon Linux 2 EOL. | ✅ Fase 2 (sin EC2) |
| E-10 | Alarma de scale-down con operador incorrecto. | ✅ Fase 0 |
| E-11 | Alarmas de CPU duplicadas. | ✅ Fase 2 |
| E-12 | ALB solo HTTP, sin TLS. | ✅ Fase 3 (TLS opcional + redirect) |
| E-13 | Rol EC2 sin permisos de aplicación. | ✅ Fase 2 |
| E-14 | Egress amplio y sin Flow Logs. | ✅ Fase 3 |
| E-15 | Sin IMDSv2 ni cifrado EBS. | ✅ Fase 2 (Fargate) |
| E-16 | `apply` no consumía el plan / sin gate. | ✅ Fases 0–1 |
| E-17 | Región hardcodeada distinta de `var.region`. | ✅ Fase 0 |
| E-18 | Credenciales estáticas y actions obsoletas. | ✅ Fase 3 (OIDC) |

### P2 — Medias

| ID | Problema | Estado |
|---|---|---|
| E-19 | 3 NAT Gateways; sin VPC Endpoints. | ⏳ Fase 6 |
| E-20 | DynamoDB sin PITR, SSE ni deletion protection. | ✅ Fase 3 |
| E-21 | Bucket de estado sin lifecycle. | ✅ Fase 1 / Fase 3 |
| E-22 | Grace period de 480s. | ✅ Fase 2 |
| E-23 | Valores hardcodeados. | ✅ Fase 2 |
| E-24 | Sin `required_version` y lockfile ignorado. | ✅ Fase 0 |
| E-25 | Tags incompletos. | ✅ `Project`/`Environment`/`Layer` |
| E-26 | `.gitignore` con `*.exe.`. | ✅ Fase 0 |
| E-27 | Sin `tflint` ni tests. | ✅ Fase 5 (`terraform test`, tflint/trivy bloqueantes) |
| E-28 | Sin logs, dashboards ni alarmas de 5xx. | ✅ Fase 4 |
| E-29 | CI duplicado; `branches: ['*']`. | ✅ Fase 0 |

### Documentación

| ID | Problema | Estado |
|---|---|---|
| D-01 | `README.md` de 4 líneas. | ⏳ Fase 7 |
| D-02 | `design.md` contradice el código. | ⏳ Fase 7 |
| D-03 | Erratas. | ⏳ Fase 7 |
| D-04 | Diagrama apunta a una URL externa. | ⏳ Fase 7 |
| D-05 | Modelo de estado no documentado. | 🟡 Este documento + `RUNBOOK.md` |

---

## 3. Arquitectura actual

```
Internet
   │ 80 (redirect a 443 si hay certificado)
   ▼
ALB (público, 3 AZ) ── access logs ──► S3 (30 días)
   │  target group ip:8000  /health
   ▼
ECS Fargate Service (2–6 tareas, CPU target tracking)
   │            │              │
   │            │              └── CloudWatch Logs /ecs/app-3
   │            └── DynamoDB orbidi-app (rol de tarea, PITR/SSE)
   ▼
Subredes privadas (3 AZ) ──► NAT ──► ECR / APIs AWS
   │
   └── VPC Flow Logs ──► CloudWatch Logs
```

Recursos gestionados:

| Root module | Recursos |
|---|---|
| `bootstrap/` (estado local) | Bucket S3 de estado + lifecycle, tabla de locks con PITR, ECR (tags inmutables, scan on push), provider OIDC de GitHub y rol de CI |
| `terraform/` (estado remoto) | VPC, 6 subredes, IGW, 3 NAT, Flow Logs, ALB + access logs, ECS Fargate, IAM, DynamoDB, log groups, SNS, dashboard y 6 alarmas |

Decisiones:

- **ECS Fargate** en lugar de EC2 + ASG: sin parcheo de AMI ni capacidad ociosa.
- **ECR en `bootstrap/`**: rompe el ciclo imagen ↔ servicio.
- **OIDC GitHub→AWS**: sin access keys de larga duración.
- **TLS opcional** con `certificate_arn`: el ALB redirige 80→443 cuando hay certificado.
- **Tag de imagen por commit** en CI; ECR con tags inmutables.
- **Baseline de Checkov** documentado en `.checkov.yaml`.

---

## 4. Plan de ejecución por fases

### Fase 0 — Desbloqueo ✅

- [x] Provider, outputs, colisión de tablas y variables.
- [x] CI en `terraform/`, validación sin credenciales.
- [x] `versions.tf` y lockfile versionado.

### Fase 1 — Estado remoto y bootstrap ✅

- [x] `bootstrap/` con estado local propio.
- [x] Bucket S3 con versioning, SSE, ownership y public access block.
- [x] Tabla de locks con PITR.
- [x] `backend "s3"` parcial + `backend.hcl.example`.
- [x] CI genera `backend.hcl` desde STS.

### Fase 2 — Aplicación en ECS Fargate ✅

- [x] FastAPI mínima en `app/` con Dockerfile non-root.
- [x] ECR en bootstrap + build/push desde CI con tag por commit.
- [x] ECS cluster, task definition, logs, health check.
- [x] Servicio con circuit breaker y target tracking.
- [x] ALB → target group `ip:8000` con `/health`.
- [x] Roles IAM separados (ejecución/tarea).
- [x] Alarmas de CPU, 5xx y hosts no saludables.

### Fase 3 — Seguridad ✅

- [x] OIDC GitHub→AWS: provider + rol en `bootstrap/`, trust limitado a `main` y `pull_request`.
- [x] CI sin `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY`; usa `vars.AWS_ROLE_ARN`.
- [x] HTTPS opcional con ACM (`certificate_arn`), TLS 1.3/1.2, redirect 80→443 y HSTS en la app.
- [x] Security headers en FastAPI (`X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`).
- [x] Egress de tareas limitado a 443 y DNS 53.
- [x] VPC Flow Logs a CloudWatch.
- [x] DynamoDB: PITR, SSE y `deletion_protection_enabled`.
- [x] Inyección de secretos (`app_secrets`) + permiso de lectura en el rol de ejecución.
- [x] ECR con tags inmutables y scan on push.
- [x] ALB access logs a S3 con lifecycle.
- [x] Checkov bloqueante con baseline justificado; tflint y trivy.

**Pendiente de Fase 3 (movido a Fase 6):** WAF, KMS con CMK, restricción total de egress con VPC Endpoints.

### Fase 4 — Observabilidad ✅

- [x] SNS topic `${name}-alerts` + suscripción por email opcional.
- [x] Dashboard `${name}-overview`: requests, 5xx, latencia p95, CPU/memoria, hosts y tareas.
- [x] Alarmas: CPU, memoria, 5xx, unhealthy hosts, latencia p95 y tareas por debajo del mínimo.
- [x] Log group de app y de Flow Logs con retención configurable.
- [x] `RUNBOOK.md` con alarmas, rollback, escala y diagnóstico.

### Fase 5 — CI/CD maduro ✅

- [x] `terraform test` con `mock_provider` en `terraform/` y `bootstrap/` (sin credenciales).
- [x] Smoke test de `/health` después del apply.
- [x] tflint y trivy como gates bloqueantes.
- [x] `deploy` depende de `validate` + `lint`.
- [x] Required reviewers e Infracost documentados como configuración de GitHub (no versionable en el repo).

### Fase 6 — Evolución ⏳

- [ ] VPC Endpoints (S3 gateway, ECR/SSM) y 1–2 NAT por entorno.
- [ ] WAF en el ALB.
- [ ] KMS con CMK para DynamoDB, logs y ECR.
- [ ] Extraer módulos: `network`, `alb`, `ecs`, `data`, `observability`.
- [ ] Entornos `dev/staging/prod` con states separados.
- [ ] AWS Budgets y alarmas de costo.
- [ ] Backups/DR con RPO/RTO y restore probado.
- [ ] Graviton (ARM64) y Savings Plans.

### Fase 7 — Documentación ⏳

- [ ] Reescribir `README.md` con quickstart, variables/outputs, CI/CD, operación y troubleshooting.
- [ ] Evolucionar `design.md` a ADR con estado actual vs objetivo.

---

## 5. Bootstrap y primer despliegue

```bash
# 1) Crear backend, ECR y rol OIDC (una sola vez, estado local)
cd bootstrap
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply

# 2) Guardar el rol para GitHub Actions
terraform output -raw github_actions_role_arn

# 3) Configurar el backend del root module principal
cd ../terraform
cp backend.hcl.example backend.hcl
# editar bucket con el account id real
terraform init -backend-config=backend.hcl

# 4) Construir y publicar la imagen (tag inmutable)
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
IMAGE="${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/orbidi/api:$(git rev-parse --short HEAD)"
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin "${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com"
docker build -t "$IMAGE" ../app
docker push "$IMAGE"

# 5) Desplegar
cp terraform.tfvars.example terraform.tfvars
terraform plan -var="image_tag=$(git rev-parse --short HEAD)" -out=tfplan.binary
terraform apply tfplan.binary

# 6) Verificar
terraform output -raw alb_dns_name   # curl http://<dns>/health
```

> Nombres por defecto compartidos: `orbidi-tfstate-<account_id>`,
> `orbidi-terraform-locks`, `orbidi/api`, rol `${project}-github-actions`.

## 6. Variables y secretos de CI

| Tipo | Nombre | Uso |
|---|---|---|
| Variable | `AWS_DEPLOY_ENABLED=true` | Habilita el job `deploy`. |
| Variable | `AWS_ROLE_ARN` | ARN del rol OIDC (`terraform output github_actions_role_arn`). |
| Variable | `AWS_REGION` | Región de despliegue (fallback `us-east-1`). |
| Variable | `ECR_REPOSITORY` | Repositorio ECR (fallback `orbidi/api`). |
| Variable | `INFRACOST_SCAN_TYPE` | Opcional; activa Infracost. |
| Secret | `INFRACOST_API_KEY` | Opcional. |

> El job `validate` no necesita credenciales. El job `deploy` usa OIDC:
> no hay access keys de larga duración.
>
> ⚠️ `AWS_DEPLOY_ENABLED=true` solo debe definirse **después** de aplicar `bootstrap/`.

---

## 7. Verificación local

```bash
# Root module principal
cd terraform
terraform fmt -check -recursive -diff
terraform init -backend=false
terraform validate

# Bootstrap
cd ../bootstrap
terraform fmt -check -recursive -diff
terraform init -backend=false
terraform validate

# App
docker build -t orbidi-api:test ../app
docker run --rm -p 8000:8000 orbidi-api:test
curl -i http://localhost:8000/health
```

Sin credenciales, `fmt` + `init -backend=false` + `validate` son el gate mínimo.

---

## 8. Ruta crítica y esfuerzo

| Fase | Esfuerzo | Riesgo si se omite |
|---|---|---|
| 0 Desbloqueo | 1–2 d | Nada compila; CI da falsa confianza |
| 1 Estado remoto | 1 d | Pérdida/corrupción de estado |
| 2 App funcionando | 3–5 d | Infra “verde” pero sin servicio real |
| 3 Seguridad | 2–3 d | HTTP en claro, credenciales, egress abierto |
| 4 Observabilidad | 2–3 d | Fallos invisibles, MTTR alto |
| 5 CI/CD maduro | 2 d | Deploys sin control |
| 6 Evolución | continuo | Deuda técnica y costo |
| 7 Documentación | 1–2 d | Brecha docs↔código |

**Próximo paso:** Fase 6 (WAF, KMS, VPC Endpoints, módulos y entornos).
