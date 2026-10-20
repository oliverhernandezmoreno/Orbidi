terraform {
  backend "s3" {
    # Configuración parcial: bucket, key, region y dynamodb_table se pasan
    # con -backend-config=backend.hcl (ver backend.hcl.example).
    # El bucket y la tabla los crea bootstrap/.
    encrypt = true
  }
}
