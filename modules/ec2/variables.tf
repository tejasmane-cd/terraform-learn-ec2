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

variable "subnet_id" {
  description = "Subnet ID where the EC2 instance will be launched."
  type        = string
}

variable "vpc_security_group_ids" {
  description = "Security group IDs attached to the EC2 instance."
  type        = list(string)
}
