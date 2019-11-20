module "sidekiq" {
  source = "../modules/gitlab_gcp_instance"

  prefix = "${var.prefix}"
  node_type = "sidekiq"
  node_count = 4

  machine_type = "n1-standard-4"
  machine_image = "${var.machine_image}"
}

output "sidekiq" {
  value = module.sidekiq
}
