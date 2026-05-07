variable "name_prefix" {
  description = "Prefix used for naming ALB resources."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the target group is created."
  type        = string
}

variable "subnet_ids" {
  description = "Public subnet IDs for the Application Load Balancer."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs attached to the Application Load Balancer."
  type        = list(string)
}
