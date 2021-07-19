data "aws_vpc" "selected" {
  id = aws_vpc.gitlab_vpc.id
  default = var.vpc_default
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.selected.id
}

resource "aws_vpc" "gitlab_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.prefix}-vpc"
  }
}

resource "aws_subnet" "pub1" {
  vpc_id                  = aws_vpc.gitlab_vpc.id
  cidr_block              = var.subpub1_cidr_block
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-subnet1pub"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_subnet" "pub2" {
  vpc_id                  = aws_vpc.gitlab_vpc.id
  cidr_block              = var.subpub2_cidr_block
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-subnet2pub"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_internet_gateway" "gitlab_gw" {
  vpc_id = aws_vpc.gitlab_vpc.id

  tags = {
    Name = "${var.prefix}-igw"
  }
}

resource "aws_default_route_table" "gitlab_vpc_rt" {
  default_route_table_id = aws_vpc.gitlab_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gitlab_gw.id
  }

  tags = {
    Name = "${var.prefix}-main-rt"
  }
}
