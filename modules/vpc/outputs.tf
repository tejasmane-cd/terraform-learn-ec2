output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_id" {
  description = "ID of the public subnet."
  value       = aws_subnet.public.id
}

output "ec2_security_group_id" {
  description = "ID of the EC2 security group."
  value       = aws_security_group.ec2.id
}
