module "pgbouncer" {
  source = "../gitlab_gcp_instance"

  prefix            = var.prefix
  node_type         = "pgbouncer"
  node_count        = var.pgbouncer_node_count
  additional_labels = var.additional_labels

  machine_type  = var.pgbouncer_machine_type
  machine_image = var.machine_image
  disk_size     = coalesce(var.pgbouncer_disk_size, var.default_disk_size)
  disk_type     = coalesce(var.pgbouncer_disk_type, var.default_disk_type)
  disks         = var.pgbouncer_disks

  vpc               = local.vpc_name
  subnet            = local.subnet_name
  zones             = var.zones
  setup_external_ip = var.setup_external_ips

  geo_site       = var.geo_site
  geo_deployment = var.geo_deployment

  allow_stopping_for_update = var.allow_stopping_for_update
  machine_secure_boot       = var.machine_secure_boot
}

output "pgbouncer" {
  value = module.pgbouncer
}

module "praefect_pgbouncer" {
  source = "../gitlab_gcp_instance"

  prefix            = var.prefix
  node_type         = "praefect-pgbouncer"
  node_count        = var.praefect_pgbouncer_node_count
  additional_labels = var.additional_labels

  machine_type  = var.praefect_pgbouncer_machine_type
  machine_image = var.machine_image
  disk_size     = coalesce(var.praefect_pgbouncer_disk_size, var.default_disk_size)
  disk_type     = coalesce(var.praefect_pgbouncer_disk_type, var.default_disk_type)
  disks         = var.praefect_pgbouncer_disks

  vpc               = local.vpc_name
  subnet            = local.subnet_name
  zones             = var.zones
  setup_external_ip = var.setup_external_ips

  geo_site       = var.geo_site
  geo_deployment = var.geo_deployment

  allow_stopping_for_update = var.allow_stopping_for_update
}

output "praefect_pgbouncer" {
  value = module.praefect_pgbouncer
}
