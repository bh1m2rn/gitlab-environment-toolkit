module "haproxy_external" {
  source = "../../modules/gitlab_gcp_instance"

  geo_role = "${var.geo_role}"
  shared_prefix = "${var.shared_prefix}"
  prefix = "${var.prefix}"
  node_type = "haproxy-external"
  node_count = 1

  machine_type = "n1-highcpu-2"
  machine_image = "${var.machine_image}"

  external_ips = ["34.74.114.214"]  # TODO: CHANGEME

  tags = ["${var.prefix}-web", "${var.prefix}-haproxy"]
}

output "haproxy_external" {
  value = module.haproxy_external
}

module "haproxy_internal" {
  source = "../../modules/gitlab_gcp_instance"

  geo_role = "${var.geo_role}"
  shared_prefix = "${var.shared_prefix}"
  prefix = "${var.prefix}"
  node_type = "haproxy-internal"
  node_count = 1

  machine_type = "n1-highcpu-2"
  machine_image = "${var.machine_image}"

  tags = ["${var.prefix}-haproxy"]
}

output "haproxy_internal" {
  value = module.haproxy_internal
}

resource "google_compute_firewall" "haproxy_stats" {
  ## firewall rules enabling the load balancer health checks
  name    = "${var.prefix}-haproxy-stats-firewall-rule"
  network = "default"

  description = "Allow HAProxy Stats access"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["1936"]
  }

  target_tags   = ["${var.prefix}-haproxy"]
}
