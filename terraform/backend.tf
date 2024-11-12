terraform {
  backend "s3" {
    bucket  = "Orbidi-terraform-remote-bucket"
    encrypt = true
    key     = "tf/add-asg-elb-terraform/terraform.tfstate"
    region  = "us-east-2"
  }
}
