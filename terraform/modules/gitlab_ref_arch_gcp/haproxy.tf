module "haproxy_external" {
  source = "../gitlab_gcp_instance"

  prefix            = var.prefix
  node_type         = "haproxy-external"
  node_count        = var.haproxy_external_node_count
  additional_labels = var.additional_labels

  machine_type  = var.haproxy_external_machine_type
  machine_image = var.machine_image
  disk_size     = coalesce(var.haproxy_external_disk_size, var.default_disk_size)
  disk_type     = coalesce(var.haproxy_external_disk_type, var.default_disk_type)
  disks         = var.haproxy_external_disks

  vpc               = local.vpc_name
  subnet            = local.subnet_name
  setup_external_ip = var.setup_external_ips
  external_ips      = var.haproxy_external_external_ips

  geo_site       = var.geo_site
  geo_deployment = var.geo_deployment

  tags = distinct(concat(["${var.prefix}-web", "${var.prefix}-ssh", "${var.prefix}-haproxy", "${var.prefix}-monitor"], var.tags))
}

output "haproxy_external" {
  value = module.haproxy_external
}

module "haproxy_internal" {
  source = "../gitlab_gcp_instance"

  prefix            = var.prefix
  node_type         = "haproxy-internal"
  node_count        = var.haproxy_internal_node_count
  additional_labels = var.additional_labels

  machine_type  = var.haproxy_internal_machine_type
  machine_image = var.machine_image
  disk_size     = coalesce(var.haproxy_internal_disk_size, var.default_disk_size)
  disk_type     = coalesce(var.haproxy_internal_disk_type, var.default_disk_type)
  disks         = var.haproxy_internal_disks

  vpc               = local.vpc_name
  subnet            = local.subnet_name
  setup_external_ip = var.setup_external_ips

  geo_site       = var.geo_site
  geo_deployment = var.geo_deployment

  tags = distinct(concat(["${var.prefix}-haproxy"], var.tags))
}

output "haproxy_internal" {
  value = module.haproxy_internal
}
