output "subnet_router_instance_name" {
  value = module.tailscale_subnet_router.instance_name
}

output "subnet_router_security_group_id" {
  value = module.tailscale_subnet_router.security_group_id
}

output "subnet_router_launch_template_id" {
  value = module.tailscale_subnet_router.launch_template_id
}

output "subnet_router_autoscaling_group_id" {
  value = module.tailscale_subnet_router.autoscaling_group_id
}

output "subnet_router_role_id" {
  value = module.tailscale_subnet_router.role_id
}
