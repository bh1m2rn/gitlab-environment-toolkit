resource "aws_security_group" "gitlab_internal_networking" {
  # Allows for machine internal connections as well as outgoing internet access
  name = "${var.prefix}-internal-networking"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "gitlab_external_ssh" {
  name = "${var.prefix}-external-ssh"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "gitlab_external_git_ssh" {
  name = "${var.prefix}-external-git-ssh"
  ingress {
    from_port   = 2222
    to_port     = 2222
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "gitlab_external_http_https" {
  name = "${var.prefix}-external-http-https"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "gitlab_external_haproxy_stats" {
  name = "${var.prefix}-external-haproxy-stats"
  ingress {
    from_port   = 1936
    to_port     = 1936
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "gitlab_external_monitor" {
  name = "${var.prefix}-external-monitor"
  ingress {
    from_port   = 9122
    to_port     = 9122
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
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
  }
}

resource "aws_subnet" "pub2" {
  vpc_id                  = aws_vpc.gitlab_vpc.id
  cidr_block              = var.subpub2_cidr_block
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-subnet2pub"
  }
}

resource "aws_subnet" "pub3" {
  vpc_id                  = aws_vpc.gitlab_vpc.id
  cidr_block              = var.subpub3_cidr_block
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-subnet3pub"
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
