variable "vpc_cidr_block" {
  type = string
}
variable "subnet_config" {
  type = map(object({
    cidr_block = list(string)
    az         = list(string)
    public     = optional(bool, false)
    }
  ))
}
variable "db_name" {
  description = "database name"
  type        = string
}
variable "db_username" {
  description = "database username"
  type        = string
}
variable "db_password" {
  description = "password for database"
  type        = string
}
variable "ami" {
  description = "value of ami id"
  type        = string
}
variable "instance_type" {
  description = "value of instance type"
  type        = string
}
variable "key_name" {
  description = "value of key pair"
  type        = string
}
