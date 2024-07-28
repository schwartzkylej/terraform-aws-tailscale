locals {
  tags           = merge({ "Name" = var.name }, var.tags)
  tailscale_tags = [for t in var.tailscale_tags : "tag:${t}"]
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# add tailscale oauth client secret to parameter store
resource "aws_ssm_parameter" "this" {
  count = var.create_oauth_parameter && var.tailscale_oauth_client_secret != "" ? 1 : 0

  name  = "${var.parameter_prefix}/oauth_client_secret"
  type  = "SecureString"
  value = var.tailscale_oauth_client_secret
  tags  = local.tags
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = ["ssm:GetParameters"]
    resources = [
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.parameter_prefix}/oauth_client_secret",
    ]
  }

  statement {
    actions   = ["ec2:AssociateAddress"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "this" {
  name_prefix = "${var.name}-"
  description = "Allow Tailscale to get oauth credentials from parameter store."
  policy      = data.aws_iam_policy_document.this.json
  tags        = local.tags
}

resource "aws_iam_role" "this" {
  name_prefix        = "${var.name}-"
  assume_role_policy = data.aws_iam_policy_document.assume.json

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/EC2InstanceConnect",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    aws_iam_policy.this.arn,
  ]

  tags = local.tags
}

resource "aws_iam_instance_profile" "this" {
  role = aws_iam_role.this.name
  tags = local.tags
}

resource "aws_security_group" "this" {
  vpc_id      = var.vpc_id
  name_prefix = "${var.name}-"
  description = "Allow ALL egress from Tailscale subnet router(s)."

  tags = local.tags
}

resource "aws_security_group_rule" "egress_allow_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.this.id
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.name}-"
  image_id      = coalesce(var.ami, data.aws_ami.al2023.id)
  instance_type = var.instance_type

  update_default_version = true

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
    delete_on_termination       = true
    security_groups             = concat(var.additional_security_group_ids, [aws_security_group.this.id])
  }

  block_device_mappings {
    device_name = var.block_device_name
    ebs {
      delete_on_termination = true
      encrypted             = true
      volume_type           = var.volume_type
    }
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.this.arn
  }

  metadata_options {
    http_protocol_ipv6          = "enabled"
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  monitoring {
    enabled = var.enable_monitoring
  }

  tag_specifications {
    resource_type = "instance"
    tags          = local.tags
  }

  tag_specifications {
    resource_type = "volume"
    tags          = local.tags
  }

  lifecycle {
    create_before_destroy = true
  }

  user_data = base64encode(templatefile("${path.module}/user-data.sh.tftpl",
    {
      enable_subnet_router = var.enable_subnet_router
      enable_exit_node     = var.enable_exit_node
      enable_app_connector = var.enable_app_connector
      region               = data.aws_region.current.name
      parameter_prefix     = var.parameter_prefix
      hostname             = var.name
      eip_id               = var.eip_id
      routes               = join(",", var.routes)
      tags                 = join(",", local.tailscale_tags)
    })
  )
}

resource "aws_autoscaling_group" "this" {
  name_prefix           = "${var.name}-"
  max_size              = var.max_size
  min_size              = var.min_size
  desired_capacity      = var.desired_capacity
  termination_policies  = ["OldestLaunchConfiguration"]
  protect_from_scale_in = var.protect_from_scale_in
  vpc_zone_identifier   = var.subnet_ids

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  instance_refresh {
    strategy = "Rolling"
    triggers = ["tag"]
    preferences {
      scale_in_protected_instances = var.scale_in_protected_instances
      min_healthy_percentage       = 50
    }
  }

  dynamic "tag" {
    for_each = local.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# force node rotation on a schedule
resource "aws_autoscaling_schedule" "scale_out" {
  count = var.enable_node_rotation ? 1 : 0

  scheduled_action_name  = "${var.name}-scale-out"
  min_size               = var.min_size
  max_size               = var.max_size
  desired_capacity       = var.desired_capacity + 1
  recurrence             = var.scale_out_recurrence
  time_zone              = "UTC"
  autoscaling_group_name = aws_autoscaling_group.this.name
}

resource "aws_autoscaling_schedule" "scale_in" {
  count = var.enable_node_rotation ? 1 : 0

  scheduled_action_name  = "${var.name}-scale-in"
  min_size               = var.min_size
  max_size               = var.max_size
  desired_capacity       = var.desired_capacity
  recurrence             = var.scale_in_recurrence
  time_zone              = "UTC"
  autoscaling_group_name = aws_autoscaling_group.this.name
}
