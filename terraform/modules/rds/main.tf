resource "aws_db_instance" "app_db" {
  identifier          = "app-db"
  engine              = var.engine
  instance_class      = var.instance_class
  allocated_storage   = var.storage
  db_name             = var.db_name
  username            = var.username
  password            = var.password
  skip_final_snapshot = true
}
