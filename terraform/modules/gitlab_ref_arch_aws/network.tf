locals {
  create_network = var.create_network && var.vpc_id == null && var.subnet_ids == null

  zones = length(var.availability_zones) > 0 ? var.availability_zones : data.aws_availability_zones.defaults.names
}

resource "aws_default_vpc" "default" {
  count = local.create_network ? 0 : 1
  tags = {
    Name = "Default VPC"
  }
}

data "aws_subnet_ids" "defaults" {
  count  = local.create_network ? 0 : 1
  vpc_id = aws_default_vpc.default[0].id

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

data "aws_availability_zones" "defaults" {}

# Create new network stack
resource "aws_vpc" "gitlab_vpc" {
  count                = local.create_network ? 1 : 0
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.prefix}-vpc"
  }
}

resource "aws_subnet" "gitlab_vpc_sn_pub" {
  count                   = local.create_network ? var.subnet_pub_count : 0
  vpc_id                  = aws_vpc.gitlab_vpc[0].id
  cidr_block              = var.subpub_pub_cidr_block[count.index]
  availability_zone       = local.zones[count.index % length(local.zones)]
  map_public_ip_on_launch = true

  tags = {
    Name                     = "${var.prefix}-subnet-pub-${count.index + 1}"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_internet_gateway" "gitlab_vpc_gw" {
  count  = local.create_network ? 1 : 0
  vpc_id = aws_vpc.gitlab_vpc[0].id

  tags = {
    Name = "${var.prefix}-igw"
  }
}

resource "aws_default_route_table" "gitlab_vpc_rt" {
  count                  = local.create_network ? 1 : 0
  default_route_table_id = aws_vpc.gitlab_vpc[0].default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gitlab_vpc_gw[0].id
  }

  tags = {
    Name = "${var.prefix}-main-rt"
  }
}

# Select vpc \ subnet ids if created or given, null if using defaults
locals {
  vpc_id             = local.create_network ? aws_vpc.gitlab_vpc[0].id : var.vpc_id
  subnet_ids         = local.create_network ? aws_subnet.gitlab_vpc_sn_pub[*].id : var.subnet_ids
  default_vpc_id     = local.create_network ? null : aws_default_vpc.default[0].id
  default_subnet_ids = local.create_network ? null : data.aws_subnet_ids.defaults[0].ids
}
