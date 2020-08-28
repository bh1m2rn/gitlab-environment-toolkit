module "postgres" {
  source = "../../modules/gitlab_gcp_instance"

  prefix = "${var.prefix}"
  node_type = "postgres"
  node_count = 1
  geo_role = "${var.geo_role}"

  machine_type = "n1-standard-2"
  machine_image = "${var.machine_image}"
  label_secondaries = true
}

output "postgres" {
  value = module.postgres
}
