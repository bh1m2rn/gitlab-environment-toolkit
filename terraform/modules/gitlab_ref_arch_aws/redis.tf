module "redis" {
  source = "../gitlab_aws_instance"

  prefix          = var.prefix
  node_type       = "redis"
  node_count      = var.redis_node_count
  additional_tags = var.additional_tags

  instance_type    = var.redis_instance_type
  ami_id           = var.ami_id != null ? var.ami_id : data.aws_ami.ubuntu_18_04[0].id
  disk_size        = coalesce(var.redis_disk_size, var.default_disk_size)
  disk_type        = coalesce(var.redis_disk_type, var.default_disk_type)
  disk_encrypt     = coalesce(var.redis_disk_encrypt, var.default_disk_encrypt)
  disk_kms_key_arn = var.redis_disk_kms_key_arn != null ? var.redis_disk_kms_key_arn : var.default_kms_key_arn
  data_disks       = var.redis_data_disks
  subnet_ids       = local.backend_subnet_ids

  iam_instance_policy_arns = flatten([
    var.default_iam_instance_policy_arns,
    var.redis_iam_instance_policy_arns
  ])

  ssh_key_name = aws_key_pair.ssh_key.key_name
  security_group_ids = [
    aws_security_group.gitlab_internal_networking.id,
    aws_security_group.gitlab_external_ssh.id
  ]

  geo_site       = var.geo_site
  geo_deployment = var.geo_deployment

  label_secondaries = true
}

output "redis" {
  value = module.redis
}

# Redis Separate Cache

module "redis_cache" {
  source = "../gitlab_aws_instance"

  prefix          = var.prefix
  node_type       = "redis-cache"
  node_count      = var.redis_cache_node_count
  additional_tags = var.additional_tags

  instance_type    = var.redis_cache_instance_type
  ami_id           = var.ami_id != null ? var.ami_id : data.aws_ami.ubuntu_18_04[0].id
  disk_size        = coalesce(var.redis_cache_disk_size, var.default_disk_size)
  disk_type        = coalesce(var.redis_cache_disk_type, var.default_disk_type)
  disk_encrypt     = coalesce(var.redis_cache_disk_encrypt, var.default_disk_encrypt)
  disk_kms_key_arn = var.redis_cache_disk_kms_key_arn != null ? var.redis_cache_disk_kms_key_arn : var.default_kms_key_arn
  data_disks       = var.redis_cache_data_disks
  subnet_ids       = local.backend_subnet_ids

  iam_instance_policy_arns = flatten([
    var.default_iam_instance_policy_arns,
    var.redis_cache_iam_instance_policy_arns
  ])

  ssh_key_name = aws_key_pair.ssh_key.key_name
  security_group_ids = [
    aws_security_group.gitlab_internal_networking.id,
    aws_security_group.gitlab_external_ssh.id
  ]

  geo_site       = var.geo_site
  geo_deployment = var.geo_deployment

  label_secondaries = true
}

output "redis_cache" {
  value = module.redis_cache
}

module "redis_persistent" {
  source = "../gitlab_aws_instance"

  prefix          = var.prefix
  node_type       = "redis-persistent"
  node_count      = var.redis_persistent_node_count
  additional_tags = var.additional_tags

  instance_type    = var.redis_persistent_instance_type
  ami_id           = var.ami_id != null ? var.ami_id : data.aws_ami.ubuntu_18_04[0].id
  disk_size        = coalesce(var.redis_persistent_disk_size, var.default_disk_size)
  disk_type        = coalesce(var.redis_persistent_disk_type, var.default_disk_type)
  disk_encrypt     = coalesce(var.redis_persistent_disk_encrypt, var.default_disk_encrypt)
  disk_kms_key_arn = var.redis_persistent_disk_kms_key_arn != null ? var.redis_persistent_disk_kms_key_arn : var.default_kms_key_arn
  data_disks       = var.redis_persistent_data_disks
  subnet_ids       = local.backend_subnet_ids

  iam_instance_policy_arns = flatten([
    var.default_iam_instance_policy_arns,
    var.redis_persistent_iam_instance_policy_arns
  ])

  ssh_key_name = aws_key_pair.ssh_key.key_name
  security_group_ids = [
    aws_security_group.gitlab_internal_networking.id,
    aws_security_group.gitlab_external_ssh.id
  ]

  geo_site       = var.geo_site
  geo_deployment = var.geo_deployment

  label_secondaries = true
}

output "redis_persistent" {
  value = module.redis_persistent
}
