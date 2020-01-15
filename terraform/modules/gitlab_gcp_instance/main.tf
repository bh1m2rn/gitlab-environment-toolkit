resource "google_compute_address" "gitlab" {
  count = length(var.external_ips) == 0 ? var.node_count : 0
  name = "${var.prefix}-${var.node_type}-ip-${count.index + 1}"
}

resource "google_compute_instance" "gitlab" {
  count = var.node_count
  name = "${var.prefix}-${var.node_type}-${count.index + 1}"
  machine_type = var.machine_type
  tags = var.tags
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.machine_image
      size = var.disk_size
      type = var.disk_type
    }
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  labels = {
    gitlab_cluster_name = var.shared_prefix
    gitlab_node_type = var.node_type
    gitlab_geo_role = var.geo_role
    gitlab_node_level = var.label_secondaries == true ? (count.index == 0 ? "${var.node_type}-main" : "${var.node_type}-other") : ""
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = length(var.external_ips) == 0 ? google_compute_address.gitlab[count.index].address : var.external_ips[count.index]
    }
  }

  service_account {
    scopes = ["storage-rw"]
  }

  lifecycle {
    ignore_changes = [
      min_cpu_platform
    ]
  }
}
