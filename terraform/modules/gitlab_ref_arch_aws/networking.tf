resource "aws_security_group" "gitlab_internal_networking" {
  # Allows for machine internal connections as well as outgoing internet access
  name = "${var.prefix}-internal-networking"
  vpc_id = data.aws_vpc.selected.id

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
  vpc_id = data.aws_vpc.selected.id
  ingress {
    from_port   = 2222
    to_port     = 2222
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "gitlab_external_http_https" {
  name = "${var.prefix}-external-http-https"
  vpc_id = data.aws_vpc.selected.id
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
  vpc_id = data.aws_vpc.selected.id
  ingress {
    from_port   = 1936
    to_port     = 1936
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "gitlab_external_monitor" {
  name = "${var.prefix}-external-monitor"
  vpc_id = data.aws_vpc.selected.id
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

data "aws_vpc" "selected" {
  id = var.vpc_id
  default = var.vpc_default
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.selected.id
}
