module "jaeger" {
  source = "../modules/gitlab_azure_instance"

  prefix = "${var.prefix}"
  resource_group_name = "${var.resource_group_name}"
  node_type = "jaeger"
  node_count = 0

  subnet_id = azurerm_subnet.gitlab.id
  ssh_public_key_file_path = "${var.ssh_public_key_file_path}"
  size = "Standard_D2s_v3"
}

output "jaeger" {
  value = module.jaeger
}
