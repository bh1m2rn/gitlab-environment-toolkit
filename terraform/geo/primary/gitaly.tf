module "gitaly" {
  source = "../../modules/gitlab_gcp_instance"

  prefix = "${var.prefix}"
  node_type = "gitaly"
  node_count = 1
  geo_role = "${var.geo_role}"

  disk_type = "pd-ssd"

  machine_type = "n1-standard-2"
  machine_image = "${var.machine_image}"
  label_secondaries = true
}

output "gitaly" {
  value = module.gitaly
}
