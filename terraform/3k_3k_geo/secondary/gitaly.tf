module "gitaly" {
  source = "../../modules/gitlab_gcp_instance"

  prefix = "${var.prefix}"
  node_type = "gitaly"
  node_count = 2

  geo_role = "${var.geo_role}"
  geo_group = "${var.geo_group}"

  disk_type = "pd-ssd"

  machine_type = "n1-standard-4"
  machine_image = "${var.machine_image}"
  label_secondaries = true
}

output "gitaly" {
  value = module.gitaly
}
