module "ec" {
  source = "./modules/ec"
  vpc_id = module.vpc.vpc_id
  instance_type = "t2.micro"
}
