# Orbidi
## Overview
Esta infraestructura proporciona alta disponibilidad y escalabilidad para aplicaciones desplegadas en contenedores FastAPI. La infraestructura utiliza Terraform para definir IaC y GitHub Actions para CI/CD.

## Components
1. **VPC**: Configuración de red aislada con subredes distribuidas en varias zonas de disponibilidad.
2. **Auto Scaling Group y ALB**: Escalado automático y balanceo de carga para distribuir el tráfico de manera uniforme.
3. **S3 y DynamoDB**: Gestión de estado y bloqueo de estado en Terraform.

## Technical Decisions
- **ECS vs. EKS**: Elegimos ECS para simplificar la configuración de contenedores y su integración con otros servicios de AWS.
- **GitHub Actions**: Automatización del flujo de trabajo CI/CD.

## CI/CD Workflow
1. **Build Docker Image**: Construcción de la imagen para ambas aplicaciones FastAPI.
2. **Push to ECR**: Subida de las imágenes a ECR.
3. **Deploy with Terraform**: Ejecución de Terraform en GitHub Actions para desplegar los contenedores en ECS.

## Security
- **IAM Roles**: Permisos mínimos para cada servicio.
- **Secret Management**: Uso de Secrets Manager para gestionar los secretos.


**Alta disponibilidad:** Usando ELB y Auto Scaling.
**Escalabilidad:** EC2 Auto Scaling y Terraform.
**Seguridad:** Secrets Manager para manejo de secretos y S3 + DynamoDB para estado de Terraform.
**Contenerización:** FastAPI dentro de contenedores Docker.
**Automatización:** CI/CD con GitHub Actions y Terraform.