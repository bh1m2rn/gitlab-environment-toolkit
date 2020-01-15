module "gitaly" {
  source = "../../modules/gitlab_gcp_instance"

  geo_role = "${var.geo_role}"
  shared_prefix = "${var.shared_prefix}"
  prefix = "${var.prefix}"
  node_type = "gitaly"
  node_count = 2

  machine_type = "n1-standard-16"
  machine_image = "${var.machine_image}"
  label_secondaries = true
}

output "gitaly" {
  value = module.gitaly
}
