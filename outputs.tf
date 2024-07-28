output "instance_name" {
  value       = var.name
  description = "The name of the Tailscale EC2 instance."
}

output "security_group_id" {
  value       = aws_security_group.this.id
  description = "The ID of the Tailscale security group."
}

output "launch_template_id" {
  value       = aws_launch_template.this.id
  description = "The ID of the Tailscale launch template."
}

output "autoscaling_group_id" {
  value       = aws_autoscaling_group.this.id
  description = "The ID of the Tailscale autoscaling group."
}

output "role_id" {
  value       = aws_iam_role.this.id
  description = "The ID of IAM role attached to the Tailscale EC2 instance."
}
