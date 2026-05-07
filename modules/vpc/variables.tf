variable "name_prefix" {
  description = "Prefix used for naming VPC resources."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) >= 2
    error_message = "At least two public subnet CIDRs are required for the Application Load Balancer."
  }
}

variable "availability_zones" {
  description = "Availability zones for the public subnets."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least two availability zones are required for the Application Load Balancer."
  }
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to connect to EC2 over SSH."
  type        = string
}
