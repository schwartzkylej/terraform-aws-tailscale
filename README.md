# terraform-aws-tailscale

A terraform module to deploy a Tailscale subnet router or exit node.

## Usage

```hcl
module "tailscale_subnet_router" {
  source = "../../"

  # provision tailscale oauth secret to parameter store
  create_oauth_parameter = true
  parameter_prefix       = "/tailscale"

  # use oauth client secret and matching tags
  tailscale_oauth_client_secret = "OAUTH_CLIENT_SECRET_CHANGEME"
  tailscale_tags = ["subnet-router"]

  instance_type               = "t4g.nano"
  associate_public_ip_address = true

  name       = "tailscale"
  vpc_id     = "vpc-00000000000000000"
  subnet_ids = ["subnet-00000000000000000", "subnet-11111111111111111", "subnet-22222222222222222"]
  routes     = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]

  tags = { Name = "tailscale" }
}
```

## Examples

Examples can be found here:
* [examples/complete](examples/complete/)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.59 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.59 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_schedule.scale_in](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_schedule) | resource |
| [aws_autoscaling_schedule.scale_out](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_schedule) | resource |
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress_allow_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ssm_parameter.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ami.al2023](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_security_group_ids"></a> [additional\_security\_group\_ids](#input\_additional\_security\_group\_ids) | IDs of additional security groups for use with ECS instance. | `list(string)` | `[]` | no |
| <a name="input_ami"></a> [ami](#input\_ami) | AMI ID for use with Tailscale subnet router. | `string` | `""` | no |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | Associate public IP address for EC2 instance. | `bool` | `false` | no |
| <a name="input_block_device_name"></a> [block\_device\_name](#input\_block\_device\_name) | Mount point of root volume. | `string` | `"/dev/xvda"` | no |
| <a name="input_create_oauth_parameter"></a> [create\_oauth\_parameter](#input\_create\_oauth\_parameter) | Enable creation of SSM parameter. Must also set `tailscale_oauth_client_secret`. | `bool` | `false` | no |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | Desired capacity for the AWS Autoscaling group. | `string` | `"1"` | no |
| <a name="input_eip_id"></a> [eip\_id](#input\_eip\_id) | Assign a static EIP to the Tailscale exit node. | `string` | `""` | no |
| <a name="input_enable_app_connector"></a> [enable\_app\_connector](#input\_enable\_app\_connector) | Enable app connector feature for Tailscale deployed EC2 instance. | `bool` | `false` | no |
| <a name="input_enable_exit_node"></a> [enable\_exit\_node](#input\_enable\_exit\_node) | Enable exit node feature for Tailscale deployed EC2 instance. | `bool` | `false` | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Enable detailed monitoring for EC2 instance. | `bool` | `false` | no |
| <a name="input_enable_node_rotation"></a> [enable\_node\_rotation](#input\_enable\_node\_rotation) | Enable node rotation and patching through AWS autoscaling schedules. | `bool` | `true` | no |
| <a name="input_enable_subnet_router"></a> [enable\_subnet\_router](#input\_enable\_subnet\_router) | Enable tailscale subnet router. | `bool` | `true` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The instance type to use for the Tailscale nodes. Avoid burstable instances for production workloads. | `string` | `"t4g.nano"` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | Max size for the AWS Autoscaling group. | `string` | `"2"` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | Min size for the AWS Autoscaling group. | `string` | `"1"` | no |
| <a name="input_name"></a> [name](#input\_name) | Tailscale subnet router name. | `string` | n/a | yes |
| <a name="input_parameter_prefix"></a> [parameter\_prefix](#input\_parameter\_prefix) | SSM parameter store path with OAuth client credentials. | `string` | n/a | yes |
| <a name="input_protect_from_scale_in"></a> [protect\_from\_scale\_in](#input\_protect\_from\_scale\_in) | Whether newly launched instances are automatically protected from termination. | `bool` | `false` | no |
| <a name="input_routes"></a> [routes](#input\_routes) | List of tailscale advertised routes. | `list(string)` | n/a | yes |
| <a name="input_scale_in_protected_instances"></a> [scale\_in\_protected\_instances](#input\_scale\_in\_protected\_instances) | Behavior when encountering instances protected from scale in. Can be `Refresh`, `Ignore`, and `Wait`. | `string` | `"Ignore"` | no |
| <a name="input_scale_in_recurrence"></a> [scale\_in\_recurrence](#input\_scale\_in\_recurrence) | Cron entry to start scale in and rotation of Tailscale nodes. Removes oldest EC2 instance. Timezone is `UTC`. | `string` | `"10 8 * * 2"` | no |
| <a name="input_scale_out_recurrence"></a> [scale\_out\_recurrence](#input\_scale\_out\_recurrence) | Cron entry to start scale out and rotation of Tailscale nodes. Creates additional EC2 instance. Timezone is `UTC`. | `string` | `"5 8 * * 2"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | The subnet IDs that the Tailscale nodes will run in. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to Tailscale and AWS infrastructure. | `map(string)` | `{}` | no |
| <a name="input_tailscale_oauth_client_secret"></a> [tailscale\_oauth\_client\_secret](#input\_tailscale\_oauth\_client\_secret) | Tailscale oauth client secret. | `string` | `""` | no |
| <a name="input_tailscale_tags"></a> [tailscale\_tags](#input\_tailscale\_tags) | List of tags to advertise with Tailscale. | `list(string)` | n/a | yes |
| <a name="input_volume_type"></a> [volume\_type](#input\_volume\_type) | Volume type for Tailscale deployed EC2 instance. | `string` | `"gp3"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC that the Tailscale subnet nodes will run in. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_autoscaling_group_id"></a> [autoscaling\_group\_id](#output\_autoscaling\_group\_id) | The ID of the Tailscale autoscaling group. |
| <a name="output_instance_name"></a> [instance\_name](#output\_instance\_name) | The name of the Tailscale EC2 instance. |
| <a name="output_launch_template_id"></a> [launch\_template\_id](#output\_launch\_template\_id) | The ID of the Tailscale launch template. |
| <a name="output_role_id"></a> [role\_id](#output\_role\_id) | The ID of IAM role attached to the Tailscale EC2 instance. |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the Tailscale security group. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
