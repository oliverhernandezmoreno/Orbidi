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

Estado actual: **Fases 0, 1 y 2 completadas**. La infraestructura valida y la arquitectura de ejecución es ECS Fargate detrás del ALB.

---

## 2. Hallazgos

### P0 — Bloqueantes

| ID | Ubicación | Problema | Estado |
|---|---|---|---|
| E-01 | `terraform/providers.tf` | `profile = aws_default_security_group.default`: `profile` esperaba un string y recibía un recurso. | ✅ Fase 0 |
| E-02 | `terraform/outputs.tf` | Outputs referenciaban `aws_s3_bucket.app_bucket`, recurso inexistente. | ✅ Fase 0 |
| E-03 | `terraform/dynamodb.tf` + `providers.tf` | Dos tablas DynamoDB usaban el mismo `var.table_name`. | ✅ Fase 0 |
| E-04 | `.github/workflows/terraform.yml` | Terraform corría en la raíz; los `.tf` están en `terraform/`. | ✅ Fase 0 |
| E-05 | `terraform/variables.tf` | Variables obligatorias sin default y sin `terraform.tfvars`. | ✅ Fase 0 |
| E-06 | `terraform/providers.tf` | Sin bloque `backend "s3"`: estado local. | ✅ Fase 1 |
| E-07 | `terraform/autoscaling.tf` | `user_data` comentado: las instancias arrancaban sin aplicación. | ✅ Fase 2 (ECS Fargate) |
| E-08 | `apps/simple-app1`, `apps/simple-app2` | Gitlinks (`160000`) sin `.gitmodules` y vacíos. | ✅ Fase 2 (nueva app en `app/`) |

### P1 — Altas

| ID | Ubicación | Problema | Estado |
|---|---|---|---|
| E-09 | `terraform/variables.tf` | AMI de 2023 y Amazon Linux 2 EOL. | ✅ Fase 2 (sin EC2) |
| E-10 | `terraform/autoscaling.tf` | Scale-down con `GreaterThanOrEqualToThreshold`. | ✅ Fase 0 |
| E-11 | `terraform/cloudwatch.tf` | Alarmas de CPU duplicadas. | ✅ Fase 2 (target tracking único) |
| E-12 | `terraform/loadbalancer.tf` | ALB solo HTTP:80, sin TLS/ACM. | ⏳ Fase 3 |
| E-13 | `terraform/iamrole.tf` | Rol EC2 sin permisos de aplicación. | ✅ Fase 2 (roles de ejecución y tarea) |
| E-14 | `terraform/securitygroup.tf` | Egress amplio y sin VPC Flow Logs. | ⏳ Fase 3 |
| E-15 | `terraform/autoscaling.tf` | Sin IMDSv2 ni cifrado EBS. | ✅ Fase 2 (Fargate) |
| E-16 | `.github/workflows/terraform.yml` | `apply` no consumía el plan; sin gate. | ✅ Fases 0–1 |
| E-17 | `.github/workflows/terraform.yml` | Región hardcodeada distinta de `var.region`. | ✅ Fase 0 |
| E-18 | `.github/workflows/*.yml` | Credenciales estáticas; actions obsoletas. | 🟡 Versiones ✅ / OIDC ⏳ Fase 3 |

### P2 — Medias

| ID | Problema | Estado |
|---|---|---|
| E-19 | 3 NAT Gateways; sin VPC Endpoints. | ⏳ Fase 6 |
| E-20 | DynamoDB sin PITR, SSE ni deletion protection. | 🟡 PITR en locks (Fase 1); tabla de app ⏳ Fase 3 |
| E-21 | Bucket de estado sin lifecycle. | ✅ Fase 1 (versioning, SSE, ownership, public block) |
| E-22 | `health_check_grace_period = 480`. | ✅ Fase 2 (60s) |
| E-23 | Valores hardcodeados: puerto, path, capacidades, umbrales. | ✅ Fase 2 (variables) |
| E-24 | Sin `required_version` y lockfile ignorado. | ✅ Fase 0 |
| E-25 | Tags incompletos. | 🟡 `Project`/`Layer` agregados; CostCenter ⏳ Fase 6 |
| E-26 | `.gitignore` con `*.exe.`. | ✅ Fase 0 |
| E-27 | Sin `tflint` ni tests. | ⏳ Fase 5 |
| E-28 | Sin logs, dashboards ni alarmas de 5xx. | 🟡 Log group + 3 alarmas; dashboard ⏳ Fase 4 |
| E-29 | CI duplicado en PR; `branches: ['*']`. | ✅ Fase 0 |

### Documentación

| ID | Problema | Estado |
|---|---|---|
| D-01 | `README.md` de 4 líneas. | ⏳ Fase 7 |
| D-02 | `design.md` contradice el código (ECS/EKS, 4 subnets, 2 NAT, módulos). | ⏳ Fase 7 |
| D-03 | Erratas. | ⏳ Fase 7 |
| D-04 | Diagrama apunta a una URL externa. | ⏳ Fase 7 |
| D-05 | Modelo de estado no documentado. | 🟡 Este documento; README en Fase 7 |

---

## 3. Arquitectura actual (tras Fase 2)

```
Internet
   │ 80
   ▼
ALB (público, 3 AZ)  ──► Target Group (ip:8000, health /health)
   │
   ▼
ECS Fargate Service (2–6 tareas, target tracking CPU 70%)
   │                         │
   │                         ├── CloudWatch Logs /ecs/app-3
   │                         └── DynamoDB orbidi-app (rol de tarea)
   ▼
Subredes privadas (3 AZ) ──► NAT Gateway ──► ECR / APIs AWS
```

Recursos gestionados:

| Root module | Recursos |
|---|---|
| `bootstrap/` (estado local) | Bucket S3 de estado, tabla DynamoDB de locks, repositorio ECR + lifecycle policy |
| `terraform/` (estado remoto) | VPC, 6 subredes, IGW, 3 NAT, ALB, target group, ECS cluster/servicio/task definition, IAM, DynamoDB de app, log group, alarmas |

Decisiones:

- **ECS Fargate** en lugar de EC2 + ASG: elimina parcheo de AMI, `user_data` y capacidad ociosa.
- **ECR en `bootstrap/`**: rompe el ciclo “la imagen necesita el repo y el servicio necesita la imagen”.
- **Tag de imagen por commit** (`github.sha`) en CI: cada despliegue crea una revisión nueva de la task definition.
- **Estado remoto con bloqueo DynamoDB**, inicializado con `-backend-config`.

---

## 4. Plan de ejecución por fases

### Fase 0 — Desbloqueo ✅

- [x] Corregir provider, outputs, colisión de tablas y variables.
- [x] CI en `terraform/`, validación sin credenciales.
- [x] `versions.tf` y lockfile versionado.

### Fase 1 — Estado remoto y bootstrap ✅

- [x] `bootstrap/` con su propio estado local.
- [x] Bucket S3: versioning, SSE, ownership controls y public access block.
- [x] Tabla DynamoDB de locks con PITR.
- [x] `backend "s3"` parcial en `terraform/backend.tf` + `backend.hcl.example`.
- [x] CI genera `backend.hcl` desde `aws sts get-caller-identity`.

**DoD:** dos operadores pueden aplicar en paralelo sin corromper el estado.

### Fase 2 — Aplicación en ECS Fargate ✅

- [x] App FastAPI mínima en `app/` (`/` y `/health`) con Dockerfile no-root.
- [x] ECR en bootstrap + build/push desde CI con tag por commit.
- [x] ECS cluster con Container Insights, task definition Fargate, logs y health check.
- [x] Servicio con deployment circuit breaker y target tracking de CPU.
- [x] ALB → target group `ip:8000` con health check `/health`.
- [x] Roles IAM separados (ejecución y tarea) con permisos mínimos a DynamoDB.
- [x] Alarmas de CPU, 5xx y hosts no saludables.

**DoD:** `curl http://<alb_dns>/health` devuelve 200 y el servicio alcanza estado estable.

### Fase 3 — Seguridad ⏳

- [ ] OIDC GitHub→AWS y eliminación de access keys.
- [ ] HTTPS con ACM + redirect 80→443, HSTS.
- [ ] Restringir egress de las tareas y habilitar VPC Flow Logs.
- [ ] KMS/SSE, deletion protection y PITR en la tabla de aplicación.
- [ ] Secretos en Secrets Manager/SSM.
- [ ] Checkov con `soft_fail: false` + baseline, `tflint`, `trivy`.

### Fase 4 — Observabilidad ⏳

- [ ] Dashboard (p50/p95/p99, 5xx, CPU/memoria, tareas saludables).
- [ ] Alarmas de latencia y de tareas en ejecución por debajo de `desired_count`.
- [ ] SNS para notificaciones.
- [ ] Runbook: alarmas, rollback, escala manual.

### Fase 5 — CI/CD maduro ⏳

- [ ] `terraform test` / Terratest y smoke test post-deploy.
- [ ] Required reviewers en el environment `production`.
- [ ] Infracost estable.
- [ ] `tflint` y `trivy` como gates.

### Fase 6 — Evolución ⏳

- [ ] VPC Endpoints (S3 gateway, ECR/SSM) y 1–2 NAT por entorno.
- [ ] Extraer módulos: `network`, `alb`, `ecs`, `data`, `observability`.
- [ ] Entornos `dev/staging/prod` con states separados.
- [ ] Tagging obligatorio, AWS Budgets y alarmas de costo.
- [ ] Backups/DR con RPO/RTO y restore probado.
- [ ] Graviton (ARM64) y Savings Plans.

### Fase 7 — Documentación ⏳

- [ ] Reescribir `README.md` con quickstart, variables/outputs, CI/CD, operación y troubleshooting.
- [ ] Evolucionar `design.md` a ADR con estado actual vs objetivo.
- [ ] Generar tablas con `terraform-docs`.

---

## 5. Bootstrap y primer despliegue

```bash
# 1) Crear backend y ECR (una sola vez, estado local)
cd bootstrap
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply

# 2) Configurar el backend del root module principal
cd ../terraform
cp backend.hcl.example backend.hcl
# editar bucket con el account id real
terraform init -backend-config=backend.hcl

# 3) Construir y publicar la imagen
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin "${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com"
docker build -t "${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/orbidi/api:latest" ../app
docker push "${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/orbidi/api:latest"

# 4) Desplegar
cp terraform.tfvars.example terraform.tfvars
terraform plan -out=tfplan.binary
terraform apply tfplan.binary

# 5) Verificar
terraform output -raw alb_dns_name   # curl http://<dns>/health
```

> El backend remoto usa los mismos nombres por defecto que `bootstrap/`:
> `orbidi-tfstate-<account_id>`, `orbidi-terraform-locks` y `orbidi/api`.
> Si se cambian, ajustar `backend.hcl`, `ECR_REPOSITORY` y `ecr_repository_name`.

## 6. Variables y secretos de CI

| Tipo | Nombre | Uso |
|---|---|---|
| Variable | `AWS_DEPLOY_ENABLED=true` | Habilita el job `deploy`. |
| Variable | `AWS_REGION` | Región de despliegue (fallback `us-east-1`). |
| Variable | `ECR_REPOSITORY` | Repositorio ECR (fallback `orbidi/api`). |
| Variable | `INFRACOST_SCAN_TYPE` | Opcional; activa Infracost. |
| Secret | `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` | Credenciales hasta migrar a OIDC (Fase 3). |
| Secret | `INFRACOST_API_KEY` | Opcional. |

> El job `validate` no necesita credenciales: valida `terraform/` y `bootstrap/` en cada PR.
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
```

Sin credenciales, `fmt` + `init -backend=false` + `validate` son el gate mínimo.

---

## 8. Ruta crítica y esfuerzo

| Fase | Esfuerzo | Riesgo si se omite |
|---|---|---|
| 0 Desbloqueo | 1–2 d | Nada compila; CI da falsa confianza |
| 1 Estado remoto | 1 d | Pérdida/corrupción de estado |
| 2 App funcionando | 3–5 d | Infra “verde” pero sin servicio real |
| 3 Seguridad | 2–3 d | HTTP en claro, credenciales e IMDSv1 |
| 4 Observabilidad | 2–3 d | Fallos invisibles, MTTR alto |
| 5 CI/CD maduro | 2 d | Deploys sin control |
| 6 Evolución | continuo | Deuda técnica y costo |
| 7 Documentación | 1–2 d | Brecha docs↔código |

**Ruta crítica:** Fase 3 (seguridad) antes de exponer el servicio a producción.
