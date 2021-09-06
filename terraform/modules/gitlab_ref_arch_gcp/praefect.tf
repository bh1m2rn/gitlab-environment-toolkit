module "praefect" {
  source = "../gitlab_gcp_instance"

  prefix            = var.prefix
  node_type         = "praefect"
  node_count        = var.praefect_node_count
  additional_labels = var.additional_labels

  machine_type  = var.praefect_machine_type
  machine_image = var.machine_image
  disk_size     = coalesce(var.praefect_disk_size, var.default_disk_size)
  disk_type     = coalesce(var.praefect_disk_type, var.default_disk_type)
  disks         = var.praefect_disks

  vpc               = local.vpc_name
  subnet            = local.subnet_name
  setup_external_ip = var.setup_external_ips

  geo_site       = var.geo_site
  geo_deployment = var.geo_deployment

  label_secondaries = true
  disks             = var.praefect_disks

  service_account_roles = var.service_account_roles

  setup_external_ip = var.setup_external_ips
}

output "praefect" {
  value = module.praefect
}
