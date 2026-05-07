output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = module.alb.dns_name
}

output "asg_name" {
  description = "Name of the Auto Scaling Group."
  value       = module.ec2.asg_name
}
