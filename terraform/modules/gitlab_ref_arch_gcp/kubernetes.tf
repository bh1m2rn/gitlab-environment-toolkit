locals {
  total_node_pool_count = sum([var.webservice_node_pool_count, var.sidekiq_node_pool_count, var.supporting_node_pool_count])
}

resource "google_container_cluster" "gitlab_cluster" {
  count = min(local.total_node_pool_count, 1)
  name  = var.prefix

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

<<<<<<< HEAD
  network    = local.vpc_name
  subnetwork = local.subnet_name

=======
>>>>>>> 5499bf7 (Made changes to reflect labels and tags)
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
}

resource "google_container_node_pool" "gitlab_webservice_pool" {
  count      = min(var.webservice_node_pool_count, 1)
  name       = "${var.prefix}-webservice"
  cluster    = google_container_cluster.gitlab_cluster[count.index].name
  node_count = var.webservice_node_pool_count

  node_config {
    machine_type = var.webservice_node_pool_machine_type
    disk_type    = coalesce(var.webservice_node_pool_disk_type, var.default_disk_type)
    disk_size_gb = coalesce(var.webservice_node_pool_disk_size, var.default_disk_size)

    labels = {
      workload = "webservice"
    }
  }
}

resource "google_container_node_pool" "gitlab_sidekiq_pool" {
  count      = min(var.sidekiq_node_pool_count, 1)
  name       = "${var.prefix}-sidekiq"
  cluster    = google_container_cluster.gitlab_cluster[count.index].name
  node_count = var.sidekiq_node_pool_count

  node_config {
    machine_type = var.sidekiq_node_pool_machine_type
    disk_type    = coalesce(var.sidekiq_node_pool_disk_type, var.default_disk_type)
    disk_size_gb = coalesce(var.sidekiq_node_pool_disk_size, var.default_disk_size)

    labels = {
      workload = "sidekiq"
    }
  }
}

resource "google_container_node_pool" "gitlab_supporting_pool" {
  count      = min(var.supporting_node_pool_count, 1)
  name       = "${var.prefix}-supporting"
  cluster    = google_container_cluster.gitlab_cluster[count.index].name
  node_count = var.supporting_node_pool_count

  node_config {
    machine_type = var.supporting_node_pool_machine_type
    disk_type    = coalesce(var.supporting_node_pool_disk_type, var.default_disk_type)
    disk_size_gb = coalesce(var.supporting_node_pool_disk_size, var.default_disk_size)

    labels = {
      workload = "support"
    }
  }
}

resource "google_compute_firewall" "gitlab_kubernetes_vms_internal" {
  name    = "${var.prefix}-kubernetes-vms-internal"
<<<<<<< HEAD
  network = local.vpc_name
=======
  network = "default"
>>>>>>> 5499bf7 (Made changes to reflect labels and tags)
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