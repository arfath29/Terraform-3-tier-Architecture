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
