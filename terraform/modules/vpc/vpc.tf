module "vpc" {
  source = "./modules/vpc"
  cidr_block = "10.0.0.0/16"
  availability_zones = var.availability_zones
}