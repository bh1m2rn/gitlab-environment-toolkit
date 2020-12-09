module "gitlab_ref_arch_aws" {
  source = "../modules/gitlab_ref_arch_aws"

  prefix = var.prefix
  ssh_key = file(var.ssh_key_path)

  # 10k
  consul_node_count = 3
  consul_instance_type = "c6g.large"

  elastic_node_count = 3 
  elastic_instance_type = "c6g.4xlarge"

  gitaly_node_count = 2
  gitaly_instance_type = "m6g.4xlarge"

  gitlab_nfs_node_count = 1
  gitlab_nfs_instance_type = "c6g.xlarge"

  gitlab_rails_node_count = 3
  gitlab_rails_instance_type = "c6g.8xlarge"

  haproxy_external_node_count = 1
  haproxy_external_instance_type = "c6g.large"
  haproxy_external_elastic_ip_allocation_ids = ["eipalloc-0056bc4a0c03b063c"]
  haproxy_internal_node_count = 1
  haproxy_internal_instance_type = "c6g.large"

  monitor_node_count = 1
  monitor_instance_type = "c6g.xlarge"

  pgbouncer_node_count = 3
  pgbouncer_instance_type = "c6g.large"

  postgres_node_count = 3
  postgres_instance_type = "m6g.xlarge"

  redis_cache_node_count = 3
  redis_cache_instance_type = "m6g.xlarge"
  redis_sentinel_cache_node_count = 3
  redis_sentinel_cache_instance_type = "t4g.small"
  redis_persistent_node_count = 3
  redis_persistent_instance_type = "m6g.xlarge"
  redis_sentinel_persistent_node_count = 3
  redis_sentinel_persistent_instance_type = "t4g.small"

  sidekiq_node_count = 3
  sidekiq_instance_type = "m6g.xlarge"
}

output "gitlab_ref_arch_aws" {
  value = module.gitlab_ref_arch_aws
}
