# Runbook — Orbidi

Operación del servicio ECS Fargate detrás del ALB.

## 1. URLs y comandos útiles

```bash
cd terraform
terraform output -raw alb_dns_name
terraform output -raw ecs_cluster_name
terraform output -raw ecs_service_name
terraform output -raw log_group_name

curl -i "http://$(terraform output -raw alb_dns_name)/health"
```

Logs:

```bash
aws logs tail "$(terraform output -raw log_group_name)" --follow
```

## 2. Alarmas → acción

| Alarma | Significado | Acción |
|---|---|---|
| `app-3-ecs-cpu-high` | CPU del servicio ≥ `cpu_threshold` | Verificar tráfico; el target tracking escala hasta `max_capacity`. Revisar tareas lentas en logs. |
| `app-3-ecs-memory-high` | Memoria ≥ 80% | Revisar fugas; subir `task_memory` si es sostenido. |
| `app-3-alb-5xx` | El ALB devuelve 5xx | Revisar `/health` y logs de la app; verificar despliegue reciente. |
| `app-3-unhealthy-hosts` | Tareas fuera del target group | Revisar logs, health check `/health` y security groups. |
| `app-3-latency-p95` | p95 > `latency_threshold_ms` | Revisar CPU/memoria y dependencias (DynamoDB). |
| `app-3-running-tasks-low` | Menos tareas que `min_capacity` | Revisar eventos del servicio ECS y capacidad disponible. |

## 3. Rollback

El servicio usa deployment circuit breaker con rollback automático.
Rollback manual a una revisión anterior:

```bash
aws ecs list-task-definitions --family-prefix app-3 --sort DESC
aws ecs update-service \
  --cluster "$(terraform output -raw ecs_cluster_name)" \
  --service "$(terraform output -raw ecs_service_name)" \
  --task-definition app-3:<REVISION>
```

En Terraform: fijar `image_tag` a un tag anterior y aplicar.

## 4. Escala manual

```bash
aws ecs update-service \
  --cluster "$(terraform output -raw ecs_cluster_name)" \
  --service "$(terraform output -raw ecs_service_name)" \
  --desired-count 4
```

> Terraform ignora `desired_count` para no pelear con el auto scaling.

## 5. Despliegue de una imagen nueva

CI publica la imagen con el SHA del commit y aplica el plan.
Manualmente:

```bash
docker build -t "$ECR_REPO:$(git rev-parse --short HEAD)" app
docker push "$ECR_REPO:$(git rev-parse --short HEAD)"
cd terraform
terraform apply -var="image_tag=$(git rev-parse --short HEAD)"
```

## 6. Diagnóstico rápido

1. `aws ecs describe-services --cluster <cluster> --services <service>` → `events`.
2. `aws ecs describe-tasks` → `stoppedReason` si hay tareas que mueren.
3. Logs del servicio en CloudWatch.
4. `UnHealthyHostCount` + security groups si el health check falla.
5. Estado de Terraform: `terraform state list`.
