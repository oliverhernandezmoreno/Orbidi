resource "aws_instance" "app" {
  count = var.instance_count
  ami = var.ami_id
  instance_type = var.instance_type
  subnet_id = element(var.subnet_ids, count.index)
  key_name = var.key_name

  tags = {
    Name = "AppInstance-${count.index}"
  }
}