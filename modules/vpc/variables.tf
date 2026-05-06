variable "name_prefix" {
  description = "Prefix used for naming VPC resources."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for the public subnet."
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to connect to EC2 over SSH."
  type        = string
}
