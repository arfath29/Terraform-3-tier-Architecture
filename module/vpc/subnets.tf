locals {
  public_subnet = {
    for key, config in var.subnet_config : key => config if config.public
  }
  private_subnet = {
    for key, config in var.subnet_config : key => config if !config.public
  }
}

resource "aws_subnet" "public_subnet" {
  for_each                = local.public_subnet
  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
  tags = {
    Name = "public-${each.key}"
  }
}

# Resource for private subnets
resource "aws_subnet" "private_subnet" {
  for_each          = local.private_subnet
  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
  tags = {
    Name = "private-${each.key}"
  }
}

