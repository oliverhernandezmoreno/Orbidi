![Texto alternativo](https://github.com/oliverhernandezmoreno/Orbidi/blob/main/Orbidi.jpg)

## Resumen
Esta infraestructura proporciona alta disponibilidad y escalabilidad para aplicaciones desplegadas en contenedores FastAPI. La infraestructura utiliza Terraform para definir IaC y GitHub Actions para CI/CD. Mediante esta configuración podremos escalar horizontalmente los servidores de aplicaciones y así aumentar el rendimiento, disminuir la latencia y proporcionar tolerancia a fallas.Contaremos con cuatro subnet, un balanceador y dos nat gateway.

## Componentes
1. **VPC**: Personalizada para la seguridad y aislamiento de los recursos. Dividirla en varias subredes (privadas y públicas) en al menos dos zonas de disponibilidad para asegurar la alta disponibilidad.

2. **Auto Scaling Group y ALB**:Grupo de autoescalado con un balanceador de carga de aplicaciones para distribuir el tráfico de manera eficiente y garantizar alta disponibilidad. 

3. **S3 y DynamoDB**: S3 para almacenar el estado de Terraform y DynamoDB para el bloqueo del estado, asegurando la gestión multiusuario y evitando conflictos de estado.

4. **Instancias EC2**:Ambas aplicaciones FastAPI en contenedores Docker. Utilizar ECR (Elastic Container Registry) para almacenar las imágenes Docker, y ECS (Elastic Container Service) o EKS (Elastic Kubernetes Service) para ejecutar los contenedores en una infraestructura escalable y manejada.

## Desiciones Tecnicas
- **Terraform**: Elegi esta herramienta ya que permite la creación, modificación y destrucción de recursos de forma declarativa, lo que facilita la gestión de infraestructuras a gran escala. Al usar módulos reutilizables, puedes tener un diseño limpio y eficiente.
    - **Módulos de Terraform**: La infraestructura se organizará en módulos, lo que facilita su reutilización y mantenimiento. Los módulos más comunes incluirán:
    - **Módulo VPC**: Para crear la red privada con subredes públicas y privadas.
    - **Módulo EC2** : Para la creación de instancias EC2 que alojarán las aplicaciones.
    - **Módulo Auto Scaling**: Para manejar el escalado automático de las instancias EC2 en función del tráfico.
    - **Módulo ALB (Application Load Balancer)**: Para distribuir el tráfico entre las instancias de manera eficiente.
    - **Módulo S3**: Para gestionar el almacenamiento de archivos estáticos y backups.
    - **Módulo RDS o DynamoDB**: Para la base de datos persistente.
    - **Módulo CloudWatch**: Para la gestión de logs y métricas.
    - **Módulo IAM**: Para gestionar las políticas de acceso de la infraestructura.
- **ECS vs. EKS**: Elegi ECS para simplificar la configuración de contenedores y su integración con otros servicios de AWS.
- **GitHub Actions**: Para automatización del flujo de trabajo CI/CD.
- **Alta disponibilidad**: Elelgi ELB (Elastic Load Balancing) ofrece tres tipos de equilibradores de carga. Estas cuentan con alta disponibilidad, escalamiento automático y seguridad robusta.
- **Escalabilidad**: Elegi  EC2 Auto Scaling y Terraform.
- **Contenerización**: Elegi FastAPI dentro de contenedores Docker, por su versatilidad y la rapidez con la que evoluciona el framework y adapta los nuevas versiones Python y tecnologías afines.
- **Automatización**: CI/CD con GitHub Actions y Terraform.


## CI/CD Workflow
1. **Build Docker Image**: Construcción de la imagen para ambas aplicaciones.
2. **Push to ECR**: Subida de las imágenes a ECR.
3. **Deploy with Terraform**: Ejecución de Terraform en GitHub Actions para desplegar los contenedores en ECS.

## Seguridad
- **IAM Roles y Policies**: Configurar políticas específicas para los servicios de AWS que se utilizarán, aplicando el principio de privilegio mínimo.
- **Secret Management**: Uso de Secrets Manager para la gestión segura de credenciales .


