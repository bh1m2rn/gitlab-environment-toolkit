module "pgbouncer" {
  source = "../gitlab_gcp_instance"

  prefix            = var.prefix
  node_type         = "pgbouncer"
  node_count        = var.pgbouncer_node_count
  additional_labels = var.additional_labels
  tags              = var.tags
  vpc               = var.vpc
  subnet            = var.subnet

  machine_type  = var.pgbouncer_machine_type
  machine_image = var.machine_image
  disk_size     = coalesce(var.pgbouncer_disk_size, var.default_disk_size)
  disk_type     = coalesce(var.pgbouncer_disk_type, var.default_disk_type)

  geo_site       = var.geo_site
  geo_deployment = var.geo_deployment
  disks          = var.pgbouncer_disks

  setup_external_ip = var.setup_external_ips
}

output "pgbouncer" {
  value = module.pgbouncer
}
