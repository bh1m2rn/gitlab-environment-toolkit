module "redis_cache" {
  source = "../../modules/gitlab_gcp_instance"

  geo_role = "${var.geo_role}"
  shared_prefix = "${var.shared_prefix}"
  prefix = "${var.prefix}"
  node_type = "redis-cache"
  node_count = 3

  machine_type = "n1-standard-4"
  machine_image = "${var.machine_image}"
  label_secondaries = true
}

output "redis_cache" {
  value = module.redis_cache
}

module "redis_sentinel_cache" {
  source = "../../modules/gitlab_gcp_instance"

  geo_role = "${var.geo_role}"
  shared_prefix = "${var.shared_prefix}"
  prefix = "${var.prefix}"
  node_type = "redis-sentinel-cache"
  node_count = 3

  machine_type = "g1-small"
  machine_image = "${var.machine_image}"
  label_secondaries = true
}

output "redis_sentinel_cache" {
  value = module.redis_sentinel_cache
}

module "redis_persistent" {
  source = "../../modules/gitlab_gcp_instance"

  geo_role = "${var.geo_role}"
  shared_prefix = "${var.shared_prefix}"
  prefix = "${var.prefix}"
  node_type = "redis-persistent"
  node_count = 3

  machine_type = "n1-standard-4"
  machine_image = "${var.machine_image}"
  label_secondaries = true
}

output "redis_persistent" {
  value = module.redis_persistent
}

module "redis_sentinel_persistent" {
  source = "../../modules/gitlab_gcp_instance"

  geo_role = "${var.geo_role}"
  shared_prefix = "${var.shared_prefix}"
  prefix = "${var.prefix}"
  node_type = "redis-sentinel-persistent"
  node_count = 3

  machine_type = "g1-small"
  machine_image = "${var.machine_image}"
  label_secondaries = true
}

output "redis_sentinel_persistent" {
  value = module.redis_sentinel_persistent
}
