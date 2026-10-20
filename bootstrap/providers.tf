provider "aws" {
  region  = var.region
  profile = var.aws_profile

  default_tags {
    tags = {
      Source  = "https://github.com/oliverhernandezmoreno/Orbidi/"
      Project = "Orbidi"
      Layer   = "bootstrap"
    }
  }
}
