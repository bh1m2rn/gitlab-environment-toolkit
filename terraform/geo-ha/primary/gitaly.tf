module "gitaly" {
  source = "../../modules/gitlab_gcp_instance"

  geo_role = "${var.geo_role}"
  shared_prefix = "${var.shared_prefix}"
  prefix = "${var.prefix}"
  node_type = "gitaly"
  node_count = 1

  disk_type = "pd-ssd"
  disk_size = "20"

  machine_type = "n1-standard-2"
  machine_image = "${var.machine_image}"
  
  label_non_main_nodes = true
}

output "gitaly" {
  value = module.gitaly
}
