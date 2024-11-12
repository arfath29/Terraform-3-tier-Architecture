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
