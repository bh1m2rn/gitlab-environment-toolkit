module "haproxy" {
  source = "../modules/gitlab_gcp_instance"

  prefix = "${var.prefix}"
  node_type = "haproxy"
  node_count = 1

  machine_type = "n1-highcpu-4"
  ssh_public_key = var.ssh_public_key
  global_ip = google_compute_global_address.gitlab.address
  tags = ["${var.prefix}-web"]
}