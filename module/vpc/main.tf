resource "aws_vpc" "project_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "project_vpc"
  }
}

resource "aws_internet_gateway" "web_igw" {
  vpc_id = aws_vpc.project_vpc.id
  count  = length(local.public_subnet) > 0 ? 1 : 0
  tags = {
    Name = "web-igw"
  }
}
resource "aws_route_table" "web_rt" {
  vpc_id = aws_vpc.project_vpc.id                  #If the condition (length(local.public_subnet) > 0) is true, it returns 1.
  count  = length(local.public_subnet) > 0 ? 1 : 0 # if the condition is greater than 0(numeric term) it'll create 1 igw or else 0.
  tags = {
    Name = "web-rt"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web_igw[0].id
  }
}
resource "aws_route_table_association" "web_rt_associate" {
  for_each       = local.public_subnet
  route_table_id = aws_route_table.web_rt[each.key].id
  subnet_id      = aws_subnet.public_subnet[0].id
}

resource "aws_eip" "elastic_ip" {
  depends_on = [aws_internet_gateway.web_igw]
}

# private configurations
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = aws_subnet.private_subnet.id
  tags = {
    Name = "nat_gateway"
  }
}
resource "aws_route_table" "pvt_rt" {
  vpc_id = aws_vpc.project_vpc.id
  route {
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
    cidr_block     = "0.0.0.0/0"
  }
  tags = {
    Name = "pvt_rt"
  }
}
resource "aws_route_table_association" "pvt_rt_association" {
  route_table_id = aws_route_table.pvt_rt.id
  subnet_id      = aws_subnet.private_subnet.id
}
