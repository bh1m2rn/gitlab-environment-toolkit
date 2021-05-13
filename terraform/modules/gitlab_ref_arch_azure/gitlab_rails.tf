module "gitlab_rails" {
  source = "../gitlab_azure_instance"

  prefix = var.prefix
  node_type = "gitlab-rails"
  node_count = var.gitlab_rails_node_count

  size = var.gitlab_rails_size
  source_image_reference = var.source_image_reference
  disk_size = coalesce(var.gitlab_rails_disk_size, var.default_disk_size)
  storage_account_type = coalesce(var.gitlab_rails_storage_account_type, var.default_storage_account_type)

  resource_group_name = var.resource_group_name
  subnet_id = azurerm_subnet.gitlab.id
  vm_admin_username = var.vm_admin_username
  ssh_public_key_file_path = var.ssh_public_key_file_path
  location = var.location

  geo_site = var.geo_site
  geo_deployment = var.geo_deployment

  label_secondaries = true
}

output "gitlab_rails" {
  value = module.gitlab_rails
}