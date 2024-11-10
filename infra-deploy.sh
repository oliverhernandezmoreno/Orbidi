#!/bin/bash

# infra-deploy.sh: Script para automatizar el despliegue de infraestructura con Terraform
# Pre-requisitos: AWS CLI configurado con permisos suficientes, y Terraform instalado.

#Explicacion Script

#Setup_backend: La función setup_backend se encarga de configurar el bucket de S3 y la tabla de DynamoDB para el almacenamiento y bloqueo del estado de Terraform.
#Comprueba si los recursos ya existen antes de crearlos, lo cual es útil para evitar duplicados.

#Creación de backend.tf: Si el archivo backend.tf no existe, lo crea dinámicamente con la configuración del bucket de S3 y la tabla de bloqueo de DynamoDB.
#Inicialización de Terraform: El comando terraform init carga el backend y descarga los módulos necesarios.
#Creación y Aplicación del Plan: Crea un plan de Terraform (terraform plan -out=tfplan) y lo aplica (terraform apply tfplan).
#Esto permite revisar cualquier cambio antes de aplicarlo, asegurando que se cumplan los requisitos.

#Logging: Todo el proceso se registra en un archivo de log (deploy.log) para futuras referencias y auditoría.



# Configuración de variables
TERRAFORM_DIR="./terraform"               # Directorio de los archivos de Terraform
S3_BUCKET_NAME="bucket-de-estado-tf"   # Bucket de S3 para almacenar el estado de Terraform
DYNAMODB_TABLE="tabla-de-bloqueo-tf"   # Tabla de DynamoDB para el bloqueo del estado de Terraform
AWS_REGION="us-west-2"                    # Región de AWS donde se desplegará la infraestructura
BACKEND_CONFIG="$TERRAFORM_DIR/backend.tf" # Archivo de configuración de backend
LOG_FILE="infra-deploy.log"                     # Archivo de log

# Función para inicializar el backend si es necesario
setup_backend() {
  echo "Configurando backend de Terraform en S3 y DynamoDB..." | tee -a $LOG_FILE

  aws s3api head-bucket --bucket "$S3_BUCKET_NAME" 2>/dev/null
  if [ $? -ne 0 ]; then
    echo "Creando el bucket de S3: $S3_BUCKET_NAME..." | tee -a $LOG_FILE
    aws s3api create-bucket --bucket "$S3_BUCKET_NAME" --region "$AWS_REGION" --create-bucket-configuration LocationConstraint="$AWS_REGION"
  else
    echo "El bucket de S3 $S3_BUCKET_NAME ya existe." | tee -a $LOG_FILE
  fi

  aws dynamodb describe-table --table-name "$DYNAMODB_TABLE" 2>/dev/null
  if [ $? -ne 0 ]; then
    echo "Creando la tabla de DynamoDB para el bloqueo de estado: $DYNAMODB_TABLE..." | tee -a $LOG_FILE
    aws dynamodb create-table --table-name "$DYNAMODB_TABLE" \
      --attribute-definitions AttributeName=LockID,AttributeType=S \
      --key-schema AttributeName=LockID,KeyType=HASH \
      --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
      --region "$AWS_REGION"
  else
    echo "La tabla de DynamoDB $DYNAMODB_TABLE ya existe." | tee -a $LOG_FILE
  fi
}

# Inicializar el backend de Terraform en S3 y DynamoDB
setup_backend

# Crear el archivo backend.tf si no existe
if [ ! -f "$BACKEND_CONFIG" ]; then
  cat <<EOF > "$BACKEND_CONFIG"
terraform {
  backend "s3" {
    bucket         = "$S3_BUCKET_NAME"
    key            = "terraform/state"
    region         = "$AWS_REGION"
    dynamodb_table = "$DYNAMODB_TABLE"
    encrypt        = true
  }
}
EOF
fi

# Cambiar al directorio de Terraform
cd $TERRAFORM_DIR || exit 1

# Inicialización de Terraform
echo "Inicializando Terraform..." | tee -a ../$LOG_FILE
terraform init | tee -a ../$LOG_FILE
if [ $? -ne 0 ]; then
  echo "Error: Falló la inicialización de Terraform." | tee -a ../$LOG_FILE
  exit 1
fi

# Validación y creación del plan de Terraform
echo "Creando plan de Terraform..." | tee -a ../$LOG_FILE
terraform plan -out=tfplan | tee -a ../$LOG_FILE
if [ $? -ne 0 ]; then
  echo "Error: Falló la creación del plan de Terraform." | tee -a ../$LOG_FILE
  exit 1
fi

# Aplicar el plan de Terraform
echo "Aplicando plan de Terraform..." | tee -a ../$LOG_FILE
terraform apply "tfplan" | tee -a ../$LOG_FILE
if [ $? -ne 0 ]; then
  echo "Error: Falló la aplicación de Terraform." | tee -a ../$LOG_FILE
  exit 1
fi

# Finalización del despliegue
echo "Despliegue completado exitosamente." | tee -a ../$LOG_FILE

