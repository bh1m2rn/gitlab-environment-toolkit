module "sidekiq" {
  source = "../../modules/gitlab_gcp_instance"

  prefix = "${var.prefix}"
  node_type = "sidekiq"
  node_count = 4

  geo_role = "${var.geo_role}"
  geo_group = "${var.geo_group}"

  machine_type = "n1-standard-2"
  machine_image = "${var.machine_image}"
}

output "sidekiq" {
  value = module.sidekiq
}
