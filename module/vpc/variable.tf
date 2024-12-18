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

