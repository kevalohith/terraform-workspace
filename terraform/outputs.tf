output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_instance.web.vpc_security_group_ids
}

