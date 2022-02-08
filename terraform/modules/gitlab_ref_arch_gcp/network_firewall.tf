resource "google_compute_firewall" "gitlab_http_https" {
  count   = min(var.haproxy_external_node_count + var.monitor_node_count, 1)
  name    = "${var.prefix}-gitlab-rails-http-https"
  network = local.vpc_name

  description = "Allow external load balancer access on the ${local.vpc_name} network"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = coalescelist(var.http_allowed_ingress_cidr_blocks, var.default_allowed_ingress_cidr_blocks)
  target_tags   = ["${var.prefix}-web"]
}

resource "google_compute_firewall" "gitlab_ssh" {
  count   = min(var.haproxy_external_node_count, 1)
  name    = "${var.prefix}-gitlab-rails-ssh"
  network = local.vpc_name

  description = "Allow access to GitLab SSH via external load balancer on the ${local.vpc_name} network"

  allow {
    protocol = "tcp"
    ports    = ["2222"]
  }

  source_ranges = coalescelist(var.ssh_allowed_ingress_cidr_blocks, var.default_allowed_ingress_cidr_blocks)
  target_tags   = ["${var.prefix}-ssh"]
}

resource "google_compute_firewall" "monitor" {
  count   = var.create_influxdb_network_rule ? min(var.monitor_node_count, 1) : 0
  name    = "${var.prefix}-monitor"
  network = local.vpc_name

  description = "Allow InfluxDB exporter access on the ${local.vpc_name} network"

  allow {
    protocol = "tcp"
    ports    = ["9122"]
  }

  source_ranges = coalescelist(var.monitor_allowed_ingress_cidr_blocks, var.default_allowed_ingress_cidr_blocks)
  target_tags   = ["${var.prefix}-monitor"]
}

# Created or Existing network rules
resource "google_compute_firewall" "ssh" {
  count   = local.vpc_name != "default" ? 1 : 0
  name    = "${var.prefix}-ssh"
  network = local.vpc_name

  description = "Allow SSH access on the ${local.vpc_name} network"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  priority      = 65534
  source_ranges = coalescelist(var.external_ssh_allowed_ingress_cidr_blocks, var.default_allowed_ingress_cidr_blocks)
}

resource "google_compute_firewall" "internal" {
  count   = local.vpc_name != "default" ? 1 : 0
  name    = "${var.prefix}-internal"
  network = local.vpc_name

  description = "Allow internal traffic on the ${local.vpc_name} network"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  priority      = 65534
  source_ranges = var.default_allowed_egress_cidr_blocks
}

resource "google_compute_firewall" "icmp" {
  count   = local.vpc_name != "default" ? 1 : 0
  name    = "${var.prefix}-icmp"
  network = local.vpc_name

  description = "Allow ICMP access on the ${local.vpc_name} network"

  allow {
    protocol = "icmp"
  }

  priority      = 65534
  source_ranges = coalescelist(var.icmp_allowed_ingress_cidr_blocks, var.default_allowed_ingress_cidr_blocks)
}
