resource "aws_security_group" "gitlab_internal_networking" {
  # Allows for machine internal connections as well as outgoing internet access
  name = "${var.prefix}-internal-networking"
  description = "Allow internal network access between GitLab VMs"

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
    cidr_blocks = var.internal_egress_cidr_ranges
  }
}

resource "aws_security_group" "gitlab_external_ssh" {
  name = "${var.prefix}-external-ssh"
  description = "Allow access for SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.external_ingress_cidr_ranges
  }
}

resource "aws_security_group" "gitlab_external_git_ssh" {
  name = "${var.prefix}-external-git-ssh"
  description = "Allow access to GitLab SSH"

  ingress {
    from_port   = 2222
    to_port     = 2222
    protocol    = "tcp"
    cidr_blocks = var.external_ingress_cidr_ranges
  }
}

resource "aws_security_group" "gitlab_external_http_https" {
  name = "${var.prefix}-external-http-https"
  description = "Allow main HTTP / HTTPS access to GitLab"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.external_ingress_cidr_ranges
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.external_ingress_cidr_ranges
}

resource "aws_security_group" "gitlab_external_haproxy_stats" {
  name = "${var.prefix}-external-haproxy-stats"
  description = "Allow HAProxy Stats access"

  ingress {
    from_port   = 1936
    to_port     = 1936
    protocol    = "tcp"
    cidr_blocks = var.external_ingress_cidr_ranges
  }
}

resource "aws_security_group" "gitlab_external_monitor" {
  name = "${var.prefix}-external-monitor"
  description = "Allow Prometheus and InfluxDB access"

  ingress {
    from_port   = 8086
    to_port     = 8086
    protocol    = "tcp"
    cidr_blocks = var.external_ingress_cidr_ranges
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = var.external_ingress_cidr_ranges
  }

  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = var.external_ingress_cidr_ranges
  }
}
