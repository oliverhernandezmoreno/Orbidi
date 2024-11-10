variable "desired_capacity" { type = number }
variable "max_size" { type = number }
variable "min_size" { type = number }
variable "subnet_ids" { type = list(string) }
variable "ami_id" { type = string }
variable "instance_type" { type = string }
variable "key_name" { type = string }