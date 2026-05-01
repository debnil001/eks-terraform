variable "cluster_name" {
  description = "EKS Cluster Name"
  type = string
}

variable "private_subnet_cidrs" {
    description = "List of CIDR blocks for private subnets"
    type = list(string)
     
}
variable "public_subnet_cidrs" {
    description = "List of CIDR blocks for public subnets"
    type = list(string)
}

variable "availability_zones" {
    description = "List of availability zones for subnets"
    type = list(string)
}
variable "vpc_cidr_block" {
    description = "CIDR block for the VPC"
    type = string
}