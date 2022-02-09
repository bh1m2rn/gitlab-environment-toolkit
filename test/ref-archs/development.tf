module "gitlab_ref_arch_aws" {
  source = "../../modules/gitlab_ref_arch_aws"

  prefix = var.prefix
  ssh_public_key_file = file(var.ssh_public_key_file)

  create_network = true

  # Development arch
  webservice_node_pool_count = 3
  webservice_node_pool_instance_type =  "c5.xlarge"
  sidekiq_node_pool_count = 3
  sidekiq_node_pool_instance_type =  "m5.large"
  supporting_node_pool_count = 3
  supporting_node_pool_instance_type =  "m5.large"
  consul_node_count = 3
  consul_instance_type =  "c5.large"
  gitaly_node_count = 3
  gitaly_instance_type =  "m5.xlarge"
  praefect_node_count = 3
  praefect_instance_type =  "c5.large"
  praefect_postgres_node_count = 1
  praefect_postgres_instance_type =  "c5.large"
  gitlab_nfs_node_count = 1
  gitlab_nfs_instance_type =  "c5.xlarge"
  haproxy_internal_node_count = 1
  haproxy_internal_instance_type =  "c5.large"
  pgbouncer_node_count = 3
  pgbouncer_instance_type =  "m5.xlarge"
  postgres_node_count = 3
  postgres_instance_type =  "m5.xlarge"
  redis_node_count = 3
  redis_instance_type =  "c5.xlarge"
}

output "gitlab_ref_arch_aws" {
  value = module.gitlab_ref_arch_aws
}
