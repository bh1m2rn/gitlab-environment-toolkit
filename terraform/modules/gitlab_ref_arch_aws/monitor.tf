module "monitor" {
  source = "../gitlab_aws_instance"

  prefix = var.prefix
  node_type = "monitor"
  node_count = var.monitor_node_count

  instance_type = var.monitor_instance_type
  ami_id = coalesce(var.ami_id, data.aws_ami.ubuntu_18_04.id)
  disk_size = coalesce(var.monitor_disk_size, var.default_disk_size)
  disk_type = coalesce(var.monitor_disk_type, var.default_disk_type)
  subnet_ids = var.vpc_default || var.vpc_id != "" ? data.aws_subnet_ids.defaults.ids : aws_subnet.gitlab_vpc_sn_pub[*].id

  ssh_key_name = aws_key_pair.ssh_key.key_name
  security_group_ids = [
    aws_security_group.gitlab_internal_networking.id,
    aws_security_group.gitlab_external_ssh.id,
    aws_security_group.gitlab_external_monitor.id,
  ]

  geo_site = var.geo_site
  geo_deployment = var.geo_deployment
}

output "monitor" {
  value = module.monitor
}
