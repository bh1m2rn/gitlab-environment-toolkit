locals {
  total_node_pool_count = sum([var.webservice_node_pool_count, var.sidekiq_node_pool_count, var.supporting_node_pool_count])
  node_pool_zones       = var.kubernetes_zones != null ? var.kubernetes_zones : var.zones
}

# Separate Subnet for Cluster - Always required to prevent clashes
resource "google_compute_subnetwork" "gitlab_cluster_subnet" {
  count = min(local.total_node_pool_count, 1)

  name                     = "${var.prefix}-cluster-subnet"
  ip_cidr_range            = "10.90.0.0/16"
  network                  = local.vpc_name
  private_ip_google_access = true
}

resource "google_container_cluster" "gitlab_cluster" {
  count = min(local.total_node_pool_count, 1)
  name  = var.prefix

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  enable_shielded_nodes    = true

  network    = local.vpc_name
  subnetwork = google_compute_subnetwork.gitlab_cluster_subnet[0].name

  # Require VPC Native cluster
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/using_gke_with_terraform#vpc-native-clusters
  # Blank block enables this and picks at random
  ip_allocation_policy {}

  release_channel {
    channel = "STABLE"
  }

  resource_labels = {
    gitlab_node_prefix = var.prefix
    gitlab_node_type   = "gitlab-cluster"
  }

  node_config {
    shielded_instance_config {
      enable_secure_boot = var.machine_secure_boot
    }
  }

}

resource "google_container_node_pool" "gitlab_webservice_pool" {
  count          = min(var.webservice_node_pool_count, 1)
  name           = "${var.prefix}-webservice"
  cluster        = google_container_cluster.gitlab_cluster[0].name
  node_count     = local.node_pool_zones != null ? ceil(var.webservice_node_pool_count / length(local.node_pool_zones)) : var.webservice_node_pool_count
  node_locations = local.node_pool_zones

  node_config {
    machine_type = var.webservice_node_pool_machine_type
    disk_type    = coalesce(var.webservice_node_pool_disk_type, var.default_disk_type)
    disk_size_gb = coalesce(var.webservice_node_pool_disk_size, var.default_disk_size)

    shielded_instance_config {
      enable_secure_boot = var.machine_secure_boot
    }

    labels = {
      workload = "webservice"
    }
  }
}

resource "google_container_node_pool" "gitlab_sidekiq_pool" {
  count          = min(var.sidekiq_node_pool_count, 1)
  name           = "${var.prefix}-sidekiq"
  cluster        = google_container_cluster.gitlab_cluster[0].name
  node_count     = local.node_pool_zones != null ? ceil(var.sidekiq_node_pool_count / length(local.node_pool_zones)) : var.sidekiq_node_pool_count
  node_locations = local.node_pool_zones

  node_config {
    machine_type = var.sidekiq_node_pool_machine_type
    disk_type    = coalesce(var.sidekiq_node_pool_disk_type, var.default_disk_type)
    disk_size_gb = coalesce(var.sidekiq_node_pool_disk_size, var.default_disk_size)

    shielded_instance_config {
      enable_secure_boot = var.machine_secure_boot
    }

    labels = {
      workload = "sidekiq"
    }
  }
}

resource "google_container_node_pool" "gitlab_supporting_pool" {
  count          = min(var.supporting_node_pool_count, 1)
  name           = "${var.prefix}-supporting"
  cluster        = google_container_cluster.gitlab_cluster[0].name
  node_count     = local.node_pool_zones != null ? ceil(var.supporting_node_pool_count / length(local.node_pool_zones)) : var.supporting_node_pool_count
  node_locations = local.node_pool_zones

  node_config {
    machine_type = var.supporting_node_pool_machine_type
    disk_type    = coalesce(var.supporting_node_pool_disk_type, var.default_disk_type)
    disk_size_gb = coalesce(var.supporting_node_pool_disk_size, var.default_disk_size)
    shielded_instance_config {
      enable_secure_boot = var.machine_secure_boot
    }

    labels = {
      workload = "support"
    }
  }
}

resource "google_compute_firewall" "gitlab_kubernetes_vms_internal" {
  name    = "${var.prefix}-kubernetes-vms-internal"
  network = local.vpc_name
  count   = min(local.total_node_pool_count, 1)

  description = "Allow internal access between GitLab Kubernetes containers and VMs"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  source_ranges = [google_container_cluster.gitlab_cluster[count.index].cluster_ipv4_cidr]
}