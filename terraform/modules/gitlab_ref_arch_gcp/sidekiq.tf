module "sidekiq" {
  source = "../gitlab_gcp_instance"

  prefix = var.prefix
  node_type = "sidekiq"
  node_count = var.sidekiq_node_count

  machine_type = var.sidekiq_machine_type
  machine_image = var.machine_image
  disk_size = coalesce(var.sidekiq_disk_size, var.default_disk_size)
  disk_type = coalesce(var.sidekiq_disk_type, var.default_disk_type)

  geo_site = var.geo_site
  geo_deployment = var.geo_deployment
}

output "sidekiq" {
  value = module.sidekiq
}