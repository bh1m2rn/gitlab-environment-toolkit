module "redis" {
  source = "../gitlab_azure_instance"

  prefix = var.prefix
  node_type = "redis"
  node_count = var.redis_node_count

  size = var.redis_size
  source_image_reference = var.source_image_reference
  disk_size = coalesce(var.redis_disk_size, var.default_disk_size)
  storage_account_type = coalesce(var.redis_storage_account_type, var.default_storage_account_type)

  resource_group_name = var.resource_group_name
  subnet_id = azurerm_subnet.gitlab.id
  vm_admin_username = var.vm_admin_username
  ssh_public_key_file_path = var.ssh_public_key_file_path
  location = var.location

  geo_site = var.geo_site
  geo_deployment = var.geo_deployment

  label_secondaries = true
}

output "redis" {
  value = module.redis
}

# Redis Separated

module "redis_cache" {
  source = "../gitlab_azure_instance"

  prefix = var.prefix
  node_type = "redis-cache"
  node_count = var.redis_cache_node_count

  size = var.redis_cache_size
  source_image_reference = var.source_image_reference
  disk_size = coalesce(var.redis_cache_disk_size, var.default_disk_size)
  storage_account_type = coalesce(var.redis_cache_storage_account_type, var.default_storage_account_type)

  resource_group_name = var.resource_group_name
  subnet_id = azurerm_subnet.gitlab.id
  vm_admin_username = var.vm_admin_username
  ssh_public_key_file_path = var.ssh_public_key_file_path
  location = var.location

  geo_site = var.geo_site
  geo_deployment = var.geo_deployment

  label_secondaries = true
}

output "redis_cache" {
  value = module.redis_cache
}

module "redis_sentinel_cache" {
  source = "../gitlab_azure_instance"

  prefix = var.prefix
  node_type = "redis-sentinel-cache"
  node_count = var.redis_sentinel_cache_node_count

  size = var.redis_sentinel_cache_size
  source_image_reference = var.source_image_reference
  disk_size = coalesce(var.redis_sentinel_cache_disk_size, var.default_disk_size)
  storage_account_type = coalesce(var.redis_sentinel_cache_storage_account_type, var.default_storage_account_type)

  resource_group_name = var.resource_group_name
  subnet_id = azurerm_subnet.gitlab.id
  vm_admin_username = var.vm_admin_username
  ssh_public_key_file_path = var.ssh_public_key_file_path
  location = var.location

  geo_site = var.geo_site
  geo_deployment = var.geo_deployment

  label_secondaries = true
}

output "redis_sentinel_cache" {
  value = module.redis_sentinel_cache
}

module "redis_persistent" {
  source = "../gitlab_azure_instance"

  prefix = var.prefix
  node_type = "redis-persistent"
  node_count = var.redis_persistent_node_count

  size = var.redis_persistent_size
  source_image_reference = var.source_image_reference
  disk_size = coalesce(var.redis_persistent_disk_size, var.default_disk_size)
  storage_account_type = coalesce(var.redis_persistent_storage_account_type, var.default_storage_account_type)

  resource_group_name = var.resource_group_name
  subnet_id = azurerm_subnet.gitlab.id
  vm_admin_username = var.vm_admin_username
  ssh_public_key_file_path = var.ssh_public_key_file_path
  location = var.location

  geo_site = var.geo_site
  geo_deployment = var.geo_deployment

  label_secondaries = true
}

output "redis_persistent" {
  value = module.redis_persistent
}

module "redis_sentinel_persistent" {
  source = "../gitlab_azure_instance"

  prefix = var.prefix
  node_type = "redis-sentinel-persistent"
  node_count = var.redis_sentinel_persistent_node_count

  size = var.redis_sentinel_persistent_size
  source_image_reference = var.source_image_reference
  disk_size = coalesce(var.redis_sentinel_persistent_disk_size, var.default_disk_size)
  storage_account_type = coalesce(var.redis_sentinel_persistent_storage_account_type, var.default_storage_account_type)

  resource_group_name = var.resource_group_name
  subnet_id = azurerm_subnet.gitlab.id
  vm_admin_username = var.vm_admin_username
  ssh_public_key_file_path = var.ssh_public_key_file_path
  location = var.location

  geo_site = var.geo_site
  geo_deployment = var.geo_deployment

  label_secondaries = true
}

output "redis_sentinel_persistent" {
  value = module.redis_sentinel_persistent
}
