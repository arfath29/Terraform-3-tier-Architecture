resource "aws_instance" "webapp_instance" {
  vpc_security_group_ids = [aws_security_group.project_SG.id]
  instance_type          = var.instance_type
  subnet_id              = element(aws_subnet.public_subnet.*.id, count.index) # Dynamically selects subnet id
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

resource "aws_instance" "database_instance" {
  ami                    = "ami-0dee22c13ea7a9a67"
  instance_type          = "t2.micro"
  key_name               = "new_key"
  vpc_security_group_ids = [aws_security_group.DB_SG.id]
  subnet_id              = aws_subnet.private_subnet.id
  tags = {
    Name = "DataBase_instance"
  }
}
