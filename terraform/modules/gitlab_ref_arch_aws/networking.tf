data "aws_vpc" "selected" {
  id = var.vpc_default == true ? "" : "aws_vpc.gitlab_vpc.id"
  default = var.vpc_default
}

data "aws_subnet_ids" "all" {
  vpc_id = var.vpc_default == true ? aws_default_vpc.default.id : data.aws_vpc.selected.id
}

resource "aws_vpc" "gitlab_vpc" {

  count = var.vpc_default == true ? 0 : 1
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_default == true ? "Default VPC" : "${var.prefix}-vpc"
  }
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_subnet" "pub" {

  count = var.vpc_default == true ? 0 : var.subnet_pub_count
  vpc_id                  = data.aws_vpc.selected.id
  cidr_block              = var.subpub_cidr_block[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-subnet${count.index}pub"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_internet_gateway" "gitlab_gw" {
  count = var.vpc_default == true ? 0 : 1
  vpc_id = data.aws_vpc.selected.id

  tags = {
    Name = "${var.prefix}-igw"
  }
}

resource "aws_default_route_table" "gitlab_vpc_rt" {
  count = var.vpc_default == true ? 0 : 1
  default_route_table_id = aws_vpc.gitlab_vpc[0].default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gitlab_gw[0].id
  }

  tags = {
    Name = "${var.prefix}-main-rt"
  }
}
