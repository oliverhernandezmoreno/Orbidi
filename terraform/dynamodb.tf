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
}