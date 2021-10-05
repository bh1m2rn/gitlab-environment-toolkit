module "pgbouncer" {
  source = "../gitlab_gcp_instance"

  prefix     = var.prefix
  node_type  = "pgbouncer"
  node_count = var.pgbouncer_node_count

  machine_type  = var.pgbouncer_machine_type
  machine_image = var.machine_image
  disk_size     = coalesce(var.pgbouncer_disk_size, var.default_disk_size)
  disk_type     = coalesce(var.pgbouncer_disk_type, var.default_disk_type)
  disks         = var.pgbouncer_disks

  vpc               = local.vpc_name
  subnet            = local.subnet_name
  setup_external_ip = var.setup_external_ips

  geo_site       = var.geo_site
  geo_deployment = var.geo_deployment
}

output "pgbouncer" {
  value = module.pgbouncer
}
