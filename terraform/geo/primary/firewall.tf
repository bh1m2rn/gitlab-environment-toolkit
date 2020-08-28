resource "google_compute_firewall" "gitlab_http_https" {
  name    = "${var.prefix}gitlab-rails-firewall-rule-http-https"
  network = "default"

  description = "Allow Google health checks and network load balancers access"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  target_tags   = ["${var.prefix}-web"]
}

resource "google_compute_firewall" "haproxy_stats" {
  ## firewall rules enabling the load balancer health checks
  name    = "${var.prefix}haproxy-stats-firewall-rule"
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