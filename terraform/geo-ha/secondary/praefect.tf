module "praefect" {
  source = "../../modules/gitlab_gcp_instance"

  geo_role = "${var.geo_role}"
  shared_prefix = "${var.shared_prefix}"
  prefix = "${var.prefix}"
  node_type = "praefect"
  node_count = 3

  machine_type = "n1-highcpu-4"
  machine_image = "${var.machine_image}"
  label_non_main_nodes = true
}

output "praefect" {
  value = module.praefect
}

module "praefect_postgres" {
  source = "../../modules/gitlab_gcp_instance"

  geo_role = "${var.geo_role}"
  shared_prefix = "${var.shared_prefix}"
  prefix = "${var.prefix}"
  node_type = "praefect-postgres"
  node_count = 1

  machine_type = "n1-standard-4"
  machine_image = "${var.machine_image}"
  label_non_main_nodes = true
}

output "praefect_postgres" {
  value = module.praefect_postgres
}
