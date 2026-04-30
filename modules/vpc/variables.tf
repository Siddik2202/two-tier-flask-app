# VPC Module vpc.variables.tf

variable "vpc_cidr" {}
variable "azs" {
  type = list(string)
}