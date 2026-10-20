# Plan de ejecución y evolución — Orbidi

> Documento de trabajo. Resume el diagnóstico de `README.md`, `design.md`, `terraform/` y `.github/workflows/`, y define el orden de corrección.
>
> **Regla de oro:** no se avanza de fase sin `terraform fmt -check`, `terraform validate` y `terraform plan` en verde.

---

## 1. Diagnóstico general

La documentación describe una arquitectura razonable (VPC multi-AZ + ALB + Auto Scaling + ECR/ECS + S3/DynamoDB + CI/CD), pero **el código no coincide con ella y, en el estado inicial, no era desplegable**:

- 4 fallos rompían `terraform validate/apply`.
- El pipeline ejecutaba Terraform en la raíz del repo, donde no hay archivos `.tf`.
- No existía `user_data`: las instancias del ASG arrancaban sin aplicación.
- El estado era local, aunque la documentación afirmaba que era remoto.

La estrategia es: **primero hacer el repo válido y reproducible**, después cerrar la brecha documentación↔código y solo entonces evolucionar (módulos, ECS/Fargate, observabilidad, entornos).

---

## 2. Hallazgos

### P0 — Bloqueantes (el proyecto no compila ni despliega)

| ID | Ubicación | Problema | Estado |
|---|---|---|---|
| E-01 | `terraform/providers.tf:13` | `profile = aws_default_security_group.default`: `profile` espera un string y recibe un recurso. `terraform validate` fallaba siempre. | ✅ Corregido (Fase 0) |
| E-02 | `terraform/outputs.tf:21,27,39` | Outputs referenciaban `aws_s3_bucket.app_bucket`, recurso inexistente. | ✅ Corregido (Fase 0) |
| E-03 | `terraform/dynamodb.tf:3` + `providers.tf:55` | Dos tablas DynamoDB usaban el mismo `var.table_name`. Apply fallaba por colisión. | ✅ Corregido (Fase 0) |
| E-04 | `.github/workflows/terraform.yml` | `init/fmt/validate/plan/apply` corrían en la raíz; los `.tf` están en `terraform/`. | ✅ Corregido (Fase 0) |
| E-05 | `terraform/variables.tf:53,218,...` | Variables obligatorias sin default y sin `terraform.tfvars`. El `plan` fallaba. | ✅ Corregido (Fase 0) |
| E-06 | `terraform/providers.tf` | Sin bloque `backend "s3"`: el estado era local pese a lo documentado. | ⏳ Fase 1 |
| E-07 | `terraform/autoscaling.tf:16` | `user_data` comentado: las instancias arrancan sin aplicación. | ⏳ Fase 2 |
| E-08 | `apps/simple-app1`, `apps/simple-app2` | Gitlinks (`160000`) sin `.gitmodules` y vacíos. No hay código de aplicación. | ⏳ Fase 2 |

### P1 — Altas (correctitud, seguridad, costo)

| ID | Ubicación | Problema | Estado |
|---|---|---|---|
| E-09 | `terraform/variables.tf:38` | AMI fijada a `amzn2-...20230727...`: formato dudoso y Amazon Linux 2 EOL (30-jun-2026). | ⏳ Fase 2 |
| E-10 | `terraform/autoscaling.tf:84-97` | Scale-down con `GreaterThanOrEqualToThreshold` y umbral 30: se dispara casi siempre y pelea con el scale-up (70). | ✅ Corregido (Fase 0, bug trivial) |
| E-11 | `terraform/cloudwatch.tf` vs `autoscaling.tf` | Alarmas de CPU duplicadas (por instancia y por ASG). | ⏳ Fase 4 |
| E-12 | `terraform/loadbalancer.tf` | ALB solo HTTP:80, sin TLS/ACM/redirect. | ⏳ Fase 3 |
| E-13 | `terraform/iamrole.tf` | El rol EC2 solo tiene `AmazonSSMManagedInstanceCore`; sin permisos a DynamoDB/S3/Secrets/Logs. | ⏳ Fase 2 |
| E-14 | `terraform/securitygroup.tf:39-47` | Egress `0.0.0.0/0` y sin VPC Flow Logs. | ⏳ Fase 3 |
| E-15 | `terraform/autoscaling.tf` | Sin `metadata_options` (IMDSv2) ni cifrado EBS. | ⏳ Fase 3 |
| E-16 | `.github/workflows/terraform.yml` | `plan` con `continue-on-error` y `apply` que no consumía el plan; apply sin gate. | ✅ Mitigado (Fase 0) / cierre en Fase 5 |
| E-17 | `.github/workflows/terraform.yml:45` | Región hardcodeada `us-east-2` vs `var.region = us-east-1`. | ✅ Corregido (Fase 0) |
| E-18 | `.github/workflows/*.yml` | Credenciales estáticas en vez de OIDC; actions obsoletas (`checkout@v3`, `configure-aws-credentials@v1`, `upload-sarif@v2` deprecada). | 🟡 Parcial (Fase 0 actualiza versiones) / OIDC en Fase 3 |

### P2 — Medias (costo, mantenibilidad, operación)

| ID | Problema | Estado |
|---|---|---|
| E-19 | 3 NAT Gateways (uno por subred pública) vs 2 documentados; sin VPC Endpoints. | ⏳ Fase 6 |
| E-20 | DynamoDB sin PITR, SSE, deletion protection ni TTL. | ⏳ Fase 3 |
| E-21 | Bucket de estado sin lifecycle ni ownership controls. | ⏳ Fase 1 |
| E-22 | `health_check_grace_period = 480`. | ⏳ Fase 2 |
| E-23 | Valores hardcodeados: puerto 80, path `/`, min/max/desired, umbrales. | ⏳ Fase 2 |
| E-24 | Sin `required_version` y `.gitignore` excluía `*.lock.hcl`. | ✅ Corregido (Fase 0) |
| E-25 | Tags incompletos. | ⏳ Fase 6 |
| E-26 | `.gitignore` con `*.exe.` (typo). | ✅ Corregido (Fase 0) |
| E-27 | Sin `tflint`, tests ni gates de seguridad. | ⏳ Fase 5 |
| E-28 | Sin log groups, dashboards ni alarmas de 5xx/latencia/UnhealthyHostCount. | ⏳ Fase 4 |
| E-29 | CI se disparaba dos veces en PR y `branches: ['*']` no matchea ramas con `/`. | ✅ Corregido (Fase 0) |

### Documentación

| ID | Problema | Estado |
|---|---|---|
| D-01 | `README.md` de 4 líneas, sin quickstart, variables, outputs ni destroy. | ⏳ Fase 7 (docs) |
| D-02 | `design.md` contradice el código: "cuatro subnets" (son 6), "dos NAT" (son 3), "ECS/EKS + ECR" (es EC2 ASG), "módulos" (no hay), Secrets Manager y backups S3 inexistentes. | ⏳ Fase 7 (docs) |
| D-03 | Erratas: "Desiciones", "Elelgi", "incluiran". | ⏳ Fase 7 (docs) |
| D-04 | La imagen del diagrama apunta a una URL externa de GitHub en vez del asset local `Orbidi.jpg`. | ⏳ Fase 7 (docs) |
| D-05 | No se documenta el modelo de estado real ni el bootstrap. | ⏳ Fase 1 / 7 |

---

## 3. Plan de ejecución por fases

### Fase 0 — Desbloqueo ✅ (esta rama)

Objetivo: que `terraform validate` y `terraform plan` sean ejecutables y que CI valide de verdad.

- [x] E-01 quitar `profile = aws_default_security_group.default`; perfil opcional vía `var.aws_profile`.
- [x] E-02 reemplazar outputs de `app_bucket` por outputs reales (VPC, subredes, ALB, ASG, estado).
- [x] E-03 separar `var.table_name` (aplicación) de `var.lock_table_name` (bloqueo de estado).
- [x] E-05 defaults seguros + `terraform.tfvars.example`; `instance_id` deja de ser obligatoria.
- [x] E-04 `working-directory: terraform` y `-backend=false` para validar sin credenciales.
- [x] E-24 `versions.tf` con `required_version` y `.terraform.lock.hcl` versionado.
- [x] E-26 corregir `.gitignore`.
- [x] E-10 corregir la alarma de scale-down.
- [x] E-17 región unificada y parametrizada.
- [x] E-29 triggers de CI sin duplicados.
- [x] Mover los recursos de estado a `terraform/state.tf` (mismo address, sin cambio de plan).
- [x] Implementar `global_secondary_index` en DynamoDB para que el output/variable sean reales.
- [x] Actualizar actions obsoletas a versiones soportadas.

**DoD:** `fmt`, `validate` y `plan` en verde; PR valida sin credenciales de AWS.

> Nota: si ya existiera estado remoto con la tabla de locks creada, E-03 requiere un bloque `moved`. En este repo no hay estado remoto todavía.

### Fase 1 — Estado remoto y bootstrap ⏳

- [ ] Crear `bootstrap/` (estado local propio) que genere bucket S3 + tabla de locks.
- [ ] Añadir `backend "s3"` con `encrypt = true` y `use_lockfile = true` (Terraform ≥ 1.10) o DynamoDB.
- [ ] `prevent_destroy`, versioning, SSE, public access block y lifecycle en el bucket.
- **DoD:** dos operadores pueden aplicar en paralelo sin corromper el estado.

### Fase 2 — Que la aplicación realmente corra ⏳

Decisión pendiente (recomendación: **Opción A**):

- **Opción A:** ECS Fargate + ECR + ALB. Elimina parcheo de AMI y capacidad ociosa; alinea el código con `design.md`.
- **Opción B:** mantener ASG con AL2023 (SSM parameter), `user_data` con Docker + ECR pull + systemd.

- [ ] E-07/E-09 resolver entrega de la aplicación.
- [ ] E-08 resolver `apps/` (submódulos reales o mover el código al monorepo).
- [ ] E-13 permisos IAM mínimos (ECR, Logs, DynamoDB/S3/Secrets).
- [ ] E-22/E-23 parametrizar grace period, puertos, paths y capacidades.
- **DoD:** `curl` al ALB devuelve 200 y `HealthyHostCount = desired`.

### Fase 3 — Seguridad ⏳

- [ ] E-18 OIDC GitHub→AWS, eliminar access keys.
- [ ] E-12 HTTPS con ACM + redirect 80→443.
- [ ] E-15 IMDSv2 obligatorio + EBS cifrado (KMS).
- [ ] E-14 restringir egress y habilitar Flow Logs.
- [ ] E-20 KMS/SSE, PITR y deletion protection en DynamoDB.
- [ ] Secretos en Secrets Manager/SSM.
- [ ] Checkov con `soft_fail: false` + baseline, `tflint`, `trivy`.
- **DoD:** 0 hallazgos críticos/altos sin justificar.

### Fase 4 — Observabilidad y operación ⏳

- [ ] E-28 log groups, dashboard (p95, 5xx, CPU, healthy hosts).
- [ ] E-11 unificar alarmas (target tracking) + SNS.
- [ ] Alarmas de `UnhealthyHostCount`, `TargetResponseTime`, `HTTPCode_ELB_5XX`.
- [ ] Runbook: alarmas, rollback, escala manual.
- **DoD:** matar una instancia/tarea genera alarma y el sistema se recupera solo.

### Fase 5 — CI/CD maduro ⏳

- [ ] E-16 `apply` del plan generado, solo en `main` y con aprobación.
- [ ] Separar `pr-validate` y `deploy` (workflow_dispatch + environment).
- [ ] `concurrency` para evitar applies simultáneos.
- [ ] E-27 `terraform test`/Terratest + smoke test post-deploy.
- [ ] Infracost estable (hoy opcional y gated).
- **DoD:** no se puede aplicar sin PR aprobado; plan y apply idénticos.

### Fase 6 — Evolución ⏳

- [ ] E-19 VPC Endpoints (S3 gateway + ECR/SSM) y 1–2 NAT por entorno.
- [ ] Extraer módulos: `network`, `alb`, `compute`, `data`, `observability`.
- [ ] Entornos `dev/staging/prod` con states separados.
- [ ] E-25 tagging obligatorio + AWS Budgets.
- [ ] Backups/DR con RPO/RTO y restore probado.
- [ ] Graviton/Spot y Savings Plans.

### Fase 7 — Documentación ⏳

- [ ] Reescribir `README.md`: badges, diagrama (Mermaid + `Orbidi.jpg` local), quickstart, variables/outputs, CI/CD, operación, costos, troubleshooting.
- [ ] Evolucionar `design.md` a ADR: estado actual vs objetivo, tabla de brechas y decisiones con consecuencias.
- [ ] Generar tablas de variables/outputs con `terraform-docs`.
- **DoD:** la documentación describe exactamente lo que el código despliega.

---

## 4. Verificación local

```bash
cd terraform
terraform fmt -check -recursive -diff
terraform init -backend=false
terraform validate
# Requiere credenciales AWS:
terraform plan -var-file=terraform.tfvars
```

Si no hay credenciales, `fmt` + `init -backend=false` + `validate` son suficientes para el gate de Fase 0.

### Variables y secretos de CI

| Tipo | Nombre | Uso |
|---|---|---|
| Variable | `AWS_DEPLOY_ENABLED=true` | Habilita el job `deploy` (plan/apply). Sin ella el pipeline solo valida. |
| Variable | `AWS_REGION` | Región de despliegue (fallback `us-east-1`). |
| Variable | `INFRACOST_SCAN_TYPE` | Opcional; activa Infracost (`tf_plan`). |
| Secret | `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` | Credenciales temporales hasta migrar a OIDC (Fase 3). |
| Secret | `INFRACOST_API_KEY` | Opcional. |

> El job `validate` no necesita credenciales: corre `fmt`, `init -backend=false` y `validate` en cada PR.
>
> ⚠️ **No definir `AWS_DEPLOY_ENABLED=true` hasta completar la Fase 1.** Sin backend remoto, cada ejecución de CI parte de un estado vacío y volvería a intentar crear los mismos recursos.

---

## 5. Ruta crítica y esfuerzo

| Fase | Esfuerzo | Riesgo si se omite |
|---|---|---|
| 0 Desbloqueo | 1–2 d | Nada compila; CI da falsa confianza |
| 1 Estado remoto | 1 d | Pérdida/corrupción de estado |
| 2 App funcionando | 3–5 d | Infra "verde" pero sin servicio real |
| 3 Seguridad | 2–3 d | HTTP en claro, credenciales e IMDSv1 |
| 4 Observabilidad | 2–3 d | Fallos invisibles, MTTR alto |
| 5 CI/CD maduro | 2 d | Deploys sin control |
| 6 Evolución | continuo | Deuda técnica y costo |

**Ruta crítica:** Fase 0 → Fase 1 → Fase 2.
