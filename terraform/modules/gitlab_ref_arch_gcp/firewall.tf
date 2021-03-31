resource "google_compute_firewall" "gitlab_http_https" {
  name    = "${var.prefix}-gitlab-rails-firewall-rule-http-https"
  description = "Allow main HTTP / HTTPS access to GitLab"
  network = "default"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = var.external_ingress_cidr_ranges
  target_tags   = ["${var.prefix}-web"]
}

resource "google_compute_firewall" "gitlab_ssh" {
  name    = "${var.prefix}-gitlab-rails-firewall-rule-ssh"
  description = "Allow access to GitLab SSH"
  network = "default"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["2222"]
  }

  source_ranges = var.external_ingress_cidr_ranges
  target_tags   = ["${var.prefix}-ssh"]
}

resource "google_compute_firewall" "haproxy_stats" {
  name    = "${var.prefix}-haproxy-stats-firewall-rule"
  description = "Allow HAProxy Stats access"
  network = "default"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["1936"]
  }

  source_ranges = var.external_ingress_cidr_ranges
  target_tags   = ["${var.prefix}-haproxy"]
}

resource "google_compute_firewall" "monitor" {
  name    = "${var.prefix}-monitor-firewall-rule"
  description = "Allow Prometheus and InfluxDB access"
  network = "default"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["8086", "9090", "5601"]
  }

  source_ranges = var.external_ingress_cidr_ranges
  target_tags   = ["${var.prefix}-monitor"]
}
