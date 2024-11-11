# Creación de la tabla DynamoDB
resource "aws_dynamodb_table" "app_table" {
  name           = var.table_name
  hash_key       = var.hash_key
  range_key      = var.range_key
  billing_mode   = var.billing_mode
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null

  attribute {
    name = var.hash_key
    type = var.hash_key_type
  }

  dynamic "attribute" {
    for_each = var.range_key != "" ? [var.range_key] : []
    content {
      name = var.range_key
      type = var.range_key_type
    }
  }

  # Configuración de índices globales secundarios (opcional)
  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name               = global_secondary_index.value["name"]
      hash_key           = global_secondary_index.value["hash_key"]
      range_key          = global_secondary_index.value.get("range_key", null)
      read_capacity      = var.billing_mode == "PROVISIONED" ? global_secondary_index.value["read_capacity"] : null
      write_capacity     = var.billing_mode == "PROVISIONED" ? global_secondary_index.value["write_capacity"] : null
      projection_type    = global_secondary_index.value["projection_type"]

      dynamic "projection" {
        for_each = global_secondary_index.value["non_key_attributes"]
        content {
          non_key_attributes = projection.value
        }
      }
    }
  }

  tags = var.tags
}
