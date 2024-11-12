resource "aws_instance" "webapp_instance" {
  vpc_security_group_ids = [aws_security_group.project_SG.id]
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  ami                    = var.ami
  count                  = 2
  key_name               = var.key_name
  user_data              = <<-EOF
            #!/bin/bash
            sudo apt update -y
            sudo apt-get install mysql-client -y
            sudo apt install docker.io -y
            sudo usermod -aG docker $USER
            sudo chown $USER /var/run/docker.sock
            sudo systemctl start docker
            sudo systemctl enable docker
            docker run --rm -p 3000:3000 -d arfath29/react-todo-app
            EOF
  tags = {
    Name = "web_${count.index}_instance"
  }
}
resource "aws_security_group" "project_SG" {
  vpc_id = aws_vpc.project_vpc.id
  tags = {
    Name = "project_SG"
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
