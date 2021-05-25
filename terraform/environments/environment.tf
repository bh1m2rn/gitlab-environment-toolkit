module "gitlab_ref_arch_gcp" {
  source = "../modules/gitlab_ref_arch_gcp"

  prefix  = var.prefix
  project = var.project

  object_storage_buckets = ["artifacts", "backups", "dependency-proxy", "lfs", "mr-diffs", "packages", "terraform-state", "uploads"]

  consul_node_count   = 3
  consul_machine_type = "n1-highcpu-2"

  elastic_node_count   = 3
  elastic_machine_type = "n1-highcpu-4"

  gitaly_node_count   = 1
  gitaly_machine_type = "n1-standard-4"

  praefect_node_count   = 1
  praefect_machine_type = "n1-highcpu-2"

  praefect_postgres_node_count   = 1
  praefect_postgres_machine_type = "n1-highcpu-2"

  gitlab_nfs_node_count   = 1
  gitlab_nfs_machine_type = "n1-highcpu-4"

  gitlab_rails_node_count   = 3
  gitlab_rails_machine_type = "n1-highcpu-4"

  haproxy_external_node_count   = 1
  haproxy_external_machine_type = "n1-highcpu-2"
  haproxy_external_external_ips = [var.external_ip]
  haproxy_internal_node_count   = 1
  haproxy_internal_machine_type = "n1-highcpu-2"

  monitor_node_count   = 1
  monitor_machine_type = "n1-highcpu-4"

  pgbouncer_node_count   = 1
  pgbouncer_machine_type = "n1-highcpu-2"

  postgres_node_count   = 3
  postgres_machine_type = "n1-standard-4"

  redis_cache_node_count                 = 3
  redis_cache_machine_type               = "n1-standard-4"
  redis_sentinel_cache_node_count        = 3
  redis_sentinel_cache_machine_type      = "n1-standard-1"
  redis_persistent_node_count            = 3
  redis_persistent_machine_type          = "n1-standard-4"
  redis_sentinel_persistent_node_count   = 3
  redis_sentinel_persistent_machine_type = "n1-standard-1"

  sidekiq_node_count   = 1
  sidekiq_machine_type = "n1-standard-4"
}

output "gitlab_ref_arch_gcp" {
  value = module.gitlab_ref_arch_gcp
}

