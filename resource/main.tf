module "vpc" {
  source                    = "../module/vpc"
  vpc_cidr_block            = var.vpc_cidr_block
  public_subnet_cidr_block  = var.public_subnet_cidr_block
  private_subnet_cidr_block = var.private_subnet_cidr_block
}
module "ec2" {
  source        = "../module/ec2"
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
}
module "RDS" {
  source      = "../module/rds"
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
}
module "lb" {
  source = "../module/lb"
}
