module "gitaly" {
  source = "../gitlab_gcp_instance"

  prefix     = var.prefix
  node_type  = "gitaly"
  node_count = var.gitaly_node_count

  machine_type  = var.gitaly_machine_type
  machine_image = var.machine_image
  disk_size     = coalesce(var.gitaly_disk_size, var.default_disk_size)
  disk_type     = coalesce(var.gitaly_disk_type, var.default_disk_type)
  disks         = var.gitaly_disks

  vpc               = local.vpc_name
  subnet            = local.subnet_name
  setup_external_ip = var.setup_external_ips

  geo_site       = var.geo_site
  geo_deployment = var.geo_deployment

  label_secondaries = true
}

output "gitaly" {
  value = module.gitaly
}
