terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "project_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "project_vpc"
  }
}
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1b"
  tags = {
    Name = "public_subnet"
  }
}
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"
  tags = {
    Name = "public_subnet_2"
  }
}
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "private_subnet"
  }
}
resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = "10.0.3.0/24" # New subnet for another AZ
  availability_zone       = "ap-south-1b" # Choose a different AZ
  map_public_ip_on_launch = false
  tags = {
    Name = "private_subnet_2"
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
resource "aws_instance" "webapp_instance" {
  vpc_security_group_ids = [aws_security_group.project_SG.id]
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  ami                    = "ami-0dee22c13ea7a9a67"
  count                  = 2
  key_name               = "new_key"
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
resource "aws_internet_gateway" "web_igw" {
  vpc_id = aws_vpc.project_vpc.id
  tags = {
    Name = "web-igw"
  }
}
resource "aws_route_table" "web_rt" {
  vpc_id = aws_vpc.project_vpc.id
  tags = {
    Name = "web-rt"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web_igw.id
  }
}
resource "aws_route_table_association" "web_rt_associate" {
  route_table_id = aws_route_table.web_rt.id
  subnet_id      = aws_subnet.public_subnet.id
}

resource "aws_db_subnet_group" "db_subnet" {
  name       = "db_private_subnet"
  subnet_ids = [aws_subnet.private_subnet.id, aws_subnet.private_subnet_2.id]
  tags = {
    Name = "db_subnet"
  }
}

resource "aws_db_instance" "project_db" {
  identifier                = "main-db"
  allocated_storage         = 20
  storage_type              = "gp2"
  engine                    = "mysql"
  instance_class            = "db.t3.micro"
  db_name                   = "tier_arc"
  username                  = "tier_3"
  password                  = "admin123"
  db_subnet_group_name      = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids    = [aws_security_group.project_SG.id]
  multi_az                  = false
  final_snapshot_identifier = "project-db-final-snapshot"
  skip_final_snapshot       = true

  tags = {
    Name = "project_db"
  }
}

resource "aws_lb" "web_LB" {
  name                       = "web-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.project_SG.id]
  subnets                    = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_2.id]
  enable_deletion_protection = false
  tags = {
    Name = "web-lb"
  }
}

resource "aws_lb_target_group" "web_tg" {
  name     = "web-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.project_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    port                = "traffic-port"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    protocol            = "HTTP"
  }

  tags = {
    Name = "web-tg"
  }
}

resource "aws_lb_target_group_attachment" "web_attachment" {
  for_each         = { for i, instance in aws_instance.webapp_instance : i => instance }
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = each.value.id
  port             = 3000
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.web_LB.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}
resource "null_resource" "db_init" {
  provisioner "local-exec" {
    command = <<EOT
      mysql -h ${aws_db_instance.project_db.endpoint} \
            -P 3306 \
            -u tier_3 \
            -p admin123 \
            -e "source ./schema.sql"
    EOT
  }

  depends_on = [aws_db_instance.project_db]
}

resource "null_resource" "db_migrations" {
  provisioner "remote-exec" {
    inline = [
      "mysql -h ${aws_db_instance.project_db.endpoint} -P 3306 -u tier_3 -p admin123 ./schema.sql"
    ]

    connection {
      type        = "ssh"
      host        = aws_instance.webapp_instance[0].public_ip
      user        = "ubuntu"
      private_key = file("./new_key.pem")
    }
  }

  depends_on = [aws_instance.webapp_instance, aws_db_instance.project_db]
}

output "load_balancer_dns_name" {
  value = aws_lb.web_LB.dns_name
}

output "rds_endpoint" {
  value = aws_db_instance.project_db.endpoint
}
