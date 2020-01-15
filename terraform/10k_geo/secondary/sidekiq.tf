module "sidekiq" {
  source = "../../modules/gitlab_gcp_instance"

  geo_role = "${var.geo_role}"
  shared_prefix = "${var.shared_prefix}"
  prefix = "${var.prefix}"
  node_type = "sidekiq"
  node_count = 4

  machine_type = "n1-standard-4"
  machine_image = "${var.machine_image}"
}

output "sidekiq" {
  value = module.sidekiq
}
