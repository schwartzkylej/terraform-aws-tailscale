data "aws_availability_zones" "available" {}

locals {
  name = "tailscale"

  vpc_cidr       = "10.0.0.0/16"
  azs            = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]

}

######################################################################
# Tailscale
######################################################################

module "tailscale_subnet_router" {
  source = "../../"

  enable_subnet_router = true

  # enable (default) node rotation and patching
  enable_node_rotation = true
  scale_out_recurrence = "0 16 * * 2"
  scale_in_recurrence  = "5 16 * * 2"

  # provision tailscale oauth secret to parameter store
  create_oauth_parameter = true
  parameter_prefix       = "/${local.name}-router"

  tailscale_oauth_client_secret = "OAUTH_CLIENT_SECRET_CHANGEME"

  # change for actual environment (example tag)
  tailscale_tags = ["subnet-router"]

  instance_type               = "t4g.small"
  associate_public_ip_address = true

  name       = "${local.name}-router"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets
  routes     = [module.vpc.vpc_cidr_block]

  tags = {
    Name = "${local.name}-router"
    Test = "true"
  }
}

######################################################################
# Tailscale Exit Node
######################################################################

module "tailscale_exit_node" {
  source = "../../"

  enable_subnet_router = false
  enable_exit_node     = true

  # disable node rotation and patching on a schedule
  enable_node_rotation = false

  # provision tailscale oauth secret to parameter store
  create_oauth_parameter = true
  parameter_prefix       = "/${local.name}-exit"

  tailscale_oauth_client_secret = "OAUTH_CLIENT_SECRET_CHANGEME"

  # change for actual environment (example tag)
  tailscale_tags = ["exit-node"]

  instance_type               = "t4g.small"
  associate_public_ip_address = true

  name       = "${local.name}-exit"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets
  routes     = [module.vpc.vpc_cidr_block]

  # use a static ip (EIP)
  eip_id = aws_eip.exit_ip.allocation_id

  tags = {
    Name = "${local.name}-exit"
    Test = "true"
  }
}

resource "aws_eip" "exit_ip" {
  domain = "vpc"
}

######################################################################
# Tailscale App Connector
######################################################################

module "tailscale_app_connector" {
  source = "../../"

  enable_subnet_router = false
  enable_app_connector = true

  # provision tailscale oauth secret to parameter store
  create_oauth_parameter = true
  parameter_prefix       = "/${local.name}-app-connector"

  tailscale_oauth_client_secret = "OAUTH_CLIENT_SECRET_CHANGEME"

  # change for actual environment (example tag)
  tailscale_tags = ["app-connector"]

  instance_type               = "t4g.small"
  associate_public_ip_address = true

  name       = "${local.name}-app-connector"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets
  routes     = [module.vpc.vpc_cidr_block]

  tags = {
    Name = "${local.name}-app-connector"
    Test = "true"
  }
}

######################################################################
# Dependencies
######################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.9.0"

  create_igw                    = true
  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false

  name           = local.name
  cidr           = local.vpc_cidr
  azs            = local.azs
  public_subnets = local.public_subnets

  tags = {
    Name = local.name
    Test = "true"
  }
}
