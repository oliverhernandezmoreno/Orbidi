provider "aws" {
  region = var.region

  # Perfil opcional de la AWS CLI. Si es null se usa la cadena de
  # credenciales por defecto (variables de entorno, SSO u OIDC en CI).
  profile = var.aws_profile

  default_tags {
    tags = {
      Source  = "https://github.com/oliverhernandezmoreno/Orbidi/"
      Project = "Orbidi"
    }
  }
}
