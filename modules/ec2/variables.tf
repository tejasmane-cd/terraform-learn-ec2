variable "ami" {
  description = "AMI ID for the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "key_name" {
  description = "Existing EC2 key pair name."
  type        = string
}

variable "name" {
  description = "Name tag for the EC2 instance."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs where the Auto Scaling Group will launch EC2 instances."
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "Security group IDs attached to the EC2 instance."
  type        = list(string)
}

variable "target_group_arns" {
  description = "Target group ARNs attached to the Auto Scaling Group."
  type        = list(string)
}

variable "desired_capacity" {
  description = "Desired number of EC2 instances in the Auto Scaling Group."
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of EC2 instances in the Auto Scaling Group."
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of EC2 instances in the Auto Scaling Group."
  type        = number
  default     = 3
}
