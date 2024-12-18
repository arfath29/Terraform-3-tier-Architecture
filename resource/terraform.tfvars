vpc_cidr_block = "10.0.0.0/16"
subnet_config = {
  "public" = {
    cidr_block = ["10.0.1.0/24", "10.0.2.0/24"]
    az         = ["ap-south-1a", "ap-south-1a"]
    public     = true
  }
  "private" = {
    cidr_block = ["10.0.3.0/24", "10.0.4.0/24"]
    az         = ["ap-south-1a", "ap-south-1b"]
  }
}
db_name       = "project_DB"
db_username   = "three_tier_arc"
db_password   = "admin123"
instance_type = "t2.micro"
ami           = "ami-0dee22c13ea7a9a67"
key_name      = "new_key"
