variable "name" {
  description = "Tailscale subnet router name."
  type        = string
}

variable "vpc_id" {
  description = "The VPC that the Tailscale subnet nodes will run in."
  type        = string
}

variable "subnet_ids" {
  description = "The subnet IDs that the Tailscale nodes will run in."
  type        = list(string)
}

variable "routes" {
  description = "List of tailscale advertised routes."
  type        = list(string)
}

variable "parameter_prefix" {
  description = "SSM parameter store path with OAuth client credentials."
  type        = string
}

variable "tailscale_tags" {
  description = "List of tags to advertise with Tailscale."
  type        = list(string)
}

######################################################################
# OAuth Secret
######################################################################

variable "create_oauth_parameter" {
  description = "Enable creation of SSM parameter. Must also set `tailscale_oauth_client_secret`."
  type        = bool
  default     = false
}

variable "tailscale_oauth_client_secret" {
  description = "Tailscale oauth client secret."
  type        = string
  default     = ""
}

######################################################################
# Optional
######################################################################

variable "enable_subnet_router" {
  description = "Enable tailscale subnet router."
  type        = bool
  default     = true
}

variable "enable_exit_node" {
  description = "Enable exit node feature for Tailscale deployed EC2 instance."
  type        = bool
  default     = false
}

variable "enable_app_connector" {
  description = "Enable app connector feature for Tailscale deployed EC2 instance."
  type        = bool
  default     = false
}

variable "enable_node_rotation" {
  description = "Enable node rotation and patching through AWS autoscaling schedules."
  type        = bool
  default     = true
}

variable "instance_type" {
  description = "The instance type to use for the Tailscale nodes. Avoid burstable instances for production workloads."
  type        = string
  default     = "t4g.nano"
}

variable "eip_id" {
  description = "Assign a static EIP to the Tailscale exit node."
  type        = string
  default     = ""
}

variable "ami" {
  description = "AMI ID for use with Tailscale subnet router."
  type        = string
  default     = ""
}

variable "volume_type" {
  description = "Volume type for Tailscale deployed EC2 instance."
  type        = string
  default     = "gp3"
}

variable "block_device_name" {
  description = "Mount point of root volume."
  type        = string
  default     = "/dev/xvda"
}

variable "desired_capacity" {
  description = "Desired capacity for the AWS Autoscaling group."
  type        = string
  default     = "1"
}

variable "max_size" {
  description = "Max size for the AWS Autoscaling group."
  type        = string
  default     = "2"
}

variable "min_size" {
  description = "Min size for the AWS Autoscaling group."
  type        = string
  default     = "1"
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring for EC2 instance."
  type        = bool
  default     = false
}

variable "protect_from_scale_in" {
  description = "Whether newly launched instances are automatically protected from termination."
  type        = bool
  default     = false
}

variable "scale_in_protected_instances" {
  description = "Behavior when encountering instances protected from scale in. Can be `Refresh`, `Ignore`, and `Wait`."
  type        = string
  default     = "Ignore"
}

variable "associate_public_ip_address" {
  description = "Associate public IP address for EC2 instance."
  type        = bool
  default     = false
}

variable "additional_security_group_ids" {
  description = "IDs of additional security groups for use with ECS instance."
  type        = list(string)
  default     = []
}

variable "scale_out_recurrence" {
  description = "Cron entry to start scale out and rotation of Tailscale nodes. Creates additional EC2 instance. Timezone is `UTC`."
  type        = string
  default     = "5 8 * * 2"
}

variable "scale_in_recurrence" {
  description = "Cron entry to start scale in and rotation of Tailscale nodes. Removes oldest EC2 instance. Timezone is `UTC`."
  type        = string
  default     = "10 8 * * 2"
}

variable "tags" {
  description = "Tags applied to Tailscale and AWS infrastructure."
  type        = map(string)
  default     = {}
}
