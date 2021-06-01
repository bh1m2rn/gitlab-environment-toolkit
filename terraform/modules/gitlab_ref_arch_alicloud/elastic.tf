module "elastic" {
  source = "../gitlab_alicloud_instance"

  prefix     = var.prefix
  node_type  = "elastic"
  node_count = var.elastic_node_count

  instance_type = var.elastic_instance_type
  image_id      = coalesce(var.image_id, data.alicloud_images.ubuntu_18_04.id)
  disk_size     = coalesce(var.elastic_disk_size, var.default_disk_size)
  disk_type     = coalesce(var.elastic_disk_type, var.default_disk_type)

  security_group_ids = [alicloud_security_group.gitlab_external_ssh.id]
  vswitch_id         = alicloud_vswitch.vswitch.id

  geo_site       = var.geo_site
  geo_deployment = var.geo_deployment

  label_secondaries = true
}

output "elastic" {
  value = module.elastic
}
