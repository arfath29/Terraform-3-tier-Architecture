output "vpc_id" {
  value = aws_vpc.main.id
}
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "instance_id" {
  value = module.ec2.instance_id
}

output "public_ip" {
  value = module.ec2.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.main.endpoint
}

