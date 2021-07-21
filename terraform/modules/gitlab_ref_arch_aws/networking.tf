resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

data "aws_subnet_ids" "defaults" {
  vpc_id = var.vpc_id != "" ? var.vpc_id : aws_default_vpc.default.id
}

data "aws_availability_zones" "defaults" {}

data "aws_vpc" "selected" {
  id = var.vpc_default ? "" : coalesce(var.vpc_id, try(aws_vpc.gitlab_vpc[0].id, null))
  default = var.vpc_id != "" ? false : var.vpc_default
}

resource "aws_vpc" "gitlab_vpc" {
  count = var.vpc_default || var.vpc_id != "" ? 0 : 1
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_default ? "Default VPC" : "${var.prefix}-vpc"
  }
}

resource "aws_subnet" "gitlab_vpc_sn_pub" {
  count = var.vpc_default || var.vpc_id != "" ? 0 : var.subnet_pub_count
  vpc_id = data.aws_vpc.selected.id
  cidr_block = var.subpub_cidr_block[count.index]
  availability_zone = data.aws_availability_zones.defaults.names[(count.index + length(data.aws_availability_zones.defaults.names)) % length(data.aws_availability_zones.defaults.names)]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-subnet-pub-${count.index}"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_internet_gateway" "gitlab_vpc_gw" {
  count = var.vpc_default || var.vpc_id != "" ? 0 : 1
  vpc_id = data.aws_vpc.selected.id

  tags = {
    Name = "${var.prefix}-igw"
  }
}

resource "aws_default_route_table" "gitlab_vpc_rt" {
  count = var.vpc_default || var.vpc_id != "" ? 0 : 1
  default_route_table_id = aws_vpc.gitlab_vpc[0].default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gitlab_vpc_gw[0].id
  }

  tags = {
    Name = "${var.prefix}-main-rt"
  }
}
