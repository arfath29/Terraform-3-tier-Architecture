resource "aws_instance" "app" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public.id
  key_name      = var.key_name

  tags = {
    Name = "app-instance"
  }

  user_data = file("${path.module}/../userdata/setup.sh")
}
