module "monitor" {
  source = "../gitlab_gcp_instance"

  prefix     = var.prefix
  node_type  = "monitor"
  node_count = var.monitor_node_count

  machine_type  = var.monitor_machine_type
  machine_image = var.machine_image
  disk_size     = coalesce(var.monitor_disk_size, var.default_disk_size)
  disk_type     = coalesce(var.monitor_disk_type, var.default_disk_type)
  disks         = var.monitor_disks

  vpc               = local.vpc_name
  subnet            = local.subnet_name
  setup_external_ip = var.setup_external_ips

  geo_site       = var.geo_site
  geo_deployment = var.geo_deployment

  tags = distinct(concat(["${var.prefix}-web"], var.tags))
}

output "monitor" {
  value = module.monitor
}
