module "monitor" {
  source = "../gitlab_gcp_instance"

  prefix = var.prefix
  node_type = "monitor"
  node_count = var.monitor_node_count

  machine_type = var.monitor_machine_type
  machine_image = var.machine_image
  disk_size = coalesce(var.monitor_disk_size, var.default_disk_size)
  disk_type = coalesce(var.monitor_disk_type, var.default_disk_type)

  geo_site = var.geo_site
  geo_deployment = var.geo_deployment

  tags = ["${var.prefix}-web"]
}

output "monitor" {
  value = module.monitor
}