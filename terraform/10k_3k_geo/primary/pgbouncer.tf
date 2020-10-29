module "pgbouncer" {
  source = "../../modules/gitlab_gcp_instance"

  prefix = "${var.prefix}"
  node_type = "pgbouncer"
  node_count = 3

  geo_role = "${var.geo_role}"
  geo_group = "${var.geo_group}"

  machine_type = "n1-highcpu-2"
  machine_image = "${var.machine_image}"
}

output "pgbouncer" {
  value = module.pgbouncer
}
