module "vpc" {
  source = "./modules/vpc"
  cidr_block = var.cidr_block
  vpc_name   = var.vpc_name
}

module "ec2" {
  source        = "./modules/ec2"
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
}

# Add similar blocks for ALB, RDS, etc.
