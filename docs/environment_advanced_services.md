# Advanced - Cloud Services

- [GitLab Environment Toolkit - Preparing the environment](environment_prep.md)
- [GitLab Environment Toolkit - Provisioning the environment with Terraform](environment_provision.md)
- [GitLab Environment Toolkit - Configuring the environment with Ansible](environment_configure.md)
- [GitLab Environment Toolkit - Advanced - Cloud Native Hybrid](environment_advanced_hybrid.md)
- [GitLab Environment Toolkit - Advanced - External SSL](environment_advanced_ssl.md)
- [**GitLab Environment Toolkit - Advanced - Cloud Services**](environment_advanced_services.md)
- [GitLab Environment Toolkit - Advanced - Geo, Advanced Search, Custom Config and more](environment_advanced.md)
- [GitLab Environment Toolkit - Upgrade Notes](environment_upgrades.md)
- [GitLab Environment Toolkit - Legacy Setups](environment_legacy.md)
- [GitLab Environment Toolkit - Considerations After Deployment - Backups, Security](environment_post_considerations.md)

The Toolkit supports using Cloud Services for select components instead of deploying them directly via Omnibus or the Helm charts - namely PostgreSQL and Redis. The Toolkit includes both provisioning and configuration of these services seamlessly within AWS.

On this page we'll detail how to setup the Toolkit to provision and configure these services. **It's worth noting this guide is supplementary to the rest of the docs and it will assume this throughout.**

[[_TOC_]]

## Overview

It can be more convenient to use a Cloud Service for select components rather than having to manage them more directly. These services have built in HA and don't require instance level maintenance.

Two components of the GitLab setup can be switched to a Cloud Service:

- [PostgreSQL](https://docs.gitlab.com/ee/administration/reference_architectures/10k_users.html#provide-your-own-postgresql-instance) - [AWS RDS](https://aws.amazon.com/rds/postgresql/), [Google Cloud SQL](https://cloud.google.com/sql/docs/postgres)
- [Redis](https://docs.gitlab.com/ee/administration/reference_architectures/10k_users.html#providing-your-own-redis-instance) - [AWS Elasticache](https://aws.amazon.com/elasticache/redis/), [Google Memorystore](https://cloud.google.com/memorystore/docs/redis)

## PostgreSQL

The Toolkit supports provisioning and configuring a PostgreSQL Cloud Service and then pointing GitLab to use it accordingly, much in the same way as configuring Omnibus Postgres.

When using a PostgreSQL Cloud Service the following changes apply when deploying via the Toolkit:

- Postgres and PgBouncer nodes don't need to be provisioned via Terraform.
- Praefect will use the same database instance. As such the Praefect Postgres node also doesn't need to be provisioned.
- Consul doesn't need to be provisioned via Terraform unless you're deploying Prometheus via the Monitor node (needed for monitoring auto discovery).

Refer to the specific cloud service section below on how to configure.

### Provisioning with Terraform

Provisioning the PostgreSQL Cloud Service differs slightly per provider but has been designed in the Toolkit to be as similar as possible to deploying PostgreSQL via Omnibus. As such, it only requires some different config in your Environment's config file (`environment.tf`).

Like the main provisioning docs there are sections for each supported provider on how to achieve this. Follow the section for your selected provider and then move onto the next step.

#### AWS RDS

The Toolkit supports provisioning an AWS RDS PostgreSQL service instance with everything GitLab requires or recommends such as built in HA support over AZs and encryption.

The variables for this service start with the prefix `rds_postgres_*` and should replace any previous `postgres_*`, `pgbouncer_*` and `praefect_postgres_*` settings. The available variables are as follows:

- `rds_postgres_instance_type`- The [AWS Instance Type](https://aws.amazon.com/rds/instance-types/) for the RDS service to use without the `db.` prefix. For example, to use a `db.m5.2xlarge` RDS instance type, the value of this variable should be `m5.2xlarge`. **Required**.
- `rds_postgres_password` - The password for the instance. **Required**.
- `rds_postgres_username` - The username for the instance. Optional, default is `gitlab`.
- `rds_postgres_database_name` - The name of the main database in the instance for use by GitLab. Optional, default is `gitlabhq_production`.
- `rds_postgres_port` - The password for the instance. Should only be changed if desired. Optional, default is `5432`.
- `rds_postgres_version` - The version of the PostgreSQL instance. Should only be changed to versions that are supported by GitLab. Optional, default is `12.6`.
- `rds_postgres_allocated_storage` - The initial disk size for the instance. Optional, default is `100`.
- `rds_postgres_max_allocated_storage` - The max disk size for the instance. Optional, default is `1000`.
- `rds_postgres_multi_az` - Specifies if the RDS instance is multi-AZ. Should only be disabled when HA isn't required. Optional, default is `true`
- `rds_postgres_iops` - The amount of provisioned IOPS. Setting this implies a storage_type of "io1". Optional, default is `1000`.
- `rds_postgres_storage_type` - The type of storage to use. Optional, default is `io1`.
- `rds_postgres_kms_key_arn` - The ARN for an existing [AWS KMS Key](https://aws.amazon.com/kms/) to be used to encrypt the database instance. If not provided a new one will be generated by Terraform for the RDS instance. Optional, default is `null`.
  - **Warning** Changing this value after the initial creation will result in the database being recreated and will lead to **data loss**.

To set up a standard AWS RDS PostgreSQL service for a 10k environment with the required variables should look like the following in your `environment.tf` file for a 10k environment is:

```tf
module "gitlab_ref_arch_aws" {
  source = "../../modules/gitlab_ref_arch_aws"

  [...]

  rds_postgres_instance_type = "m5.2xlarge"
  rds_postgres_password = "<postgres_password>"
}
```

Once the variables are set in your file you can proceed to provision the service as normal. Note that this can take several minutes on AWS's side.

Once provisioned you'll see several new outputs at the end of the process. Key from this is the `rds_address` output, which contains the address for the database instance that then needs to be passed to Ansible to configure. Take a note of this address for the next step.

### Configuring with Ansible

Configuring GitLab to use a non Omnibus PostgreSQL instance with Ansible is the same regardless of which cloud provider you choose. All that's required is a few tweaks to your [Environment config file](environment_configure.md#environment-config-varsyml) (`vars.yml`) to point the Toolkit at the PostgreSQL instance.

It's worth noting this config will also work for a custom PostgreSQL instance that has been provisioned outside of Omnibus or Cloud Services. Although please note, in this setup it's expected that HA is in place and the URL to connect to the PostgreSQL instance never changes.

The available variables in Ansible for this are as follows:

- `postgres_host` - The hostname of the PostgreSQL instance. Provided in Terraform outputs if provisioned earlier. **Required**.
- `postgres_password` - The password for the instance. **Required**.
- `postgres_username` - The username of the PostgreSQL instance. Optional, default is `gitlab`.
- `postgres_database_name` - The name of the main database in the instance for use by GitLab. Optional, default is `gitlabhq_production`.
- `postgres_port` - The port of the PostgreSQL instance. Should only be changed if the instance isn't running with the default port. Optional, default is `5432`.

Along with the above there are some additional settings specific to Praefect and how its database will be set up on the PostgreSQL instance:

- `postgres_password` - The password for the Praefect user on the PostgreSQL instance. **Required**.
- `praefect_postgres_username` - The username to create for Praefect on the PostgreSQL instance. Optional, default is `praefect`.
- `praefect_postgres_database_name` - The name of the database to create for Praefect on the PostgreSQL instance. Optional, default is `praefect_production`.

Once set, Ansible can then be run as normal. During the run it will configure the various GitLab components to use the database as well as any additional tasks such as setting up a separate database in the same instance for Praefect.

After Ansible is finished running your environment will now be ready.

## Redis

The Toolkit supports provisioning and configuring a Redis Cloud Service and then pointing GitLab to use it accordingly, much in the same way as configuring Omnibus Redis.

When using a Redis Cloud Service the following changes apply when deploying via the Toolkit:

- The Toolkit can provision either a combined Redis service or separated ones for Cache and Persistent queues respectively, much like Omnibus Redis, depending on the size of Reference Architecture being followed.
- Redis, Redis Cache or Redis Persistent nodes don't need to be provisioned via Terraform.
- [GitLab specifically doesn't support Redis Cluster](https://docs.gitlab.com/ee/administration/redis/replication_and_failover_external.html#requirements). As such the Toolkit is always setting up Redis in a replica setup.

Refer to the specific cloud service section below on how to configure.

### Provisioning with Terraform

Provisioning the Redis Cloud Service differs slightly per provider but has been designed in the Toolkit to be as similar as possible to deploying Redis via Omnibus. As such, it only requires some different config in your Environment's config file (`environment.tf`).

Like the main provisioning docs there are sections for each supported provider on how to achieve this. Follow the section for your selected provider and then move onto the next step.

#### AWS Elasticache

The Toolkit supports provisioning an AWS Elasticache Redis service instance with everything GitLab requires or recommends such as built in HA support over AZs and encryption.

There's different variables to be set depending on the target architecture size and if it requires separated Redis instances (10k and up). First we'll detail the general settings that apply to all Redis setups:

The variables to set are dependent on if the setup is to have combined or separated Redis queues depending on the target Reference Architecture. The only difference is that the prefix of each variable changes depending on what Redis instances you're provisioning - `elasticache_redis_*`, `elasticache_redis_cache_*` and `elasticache_redis_persistent_*`, each replacing any existing `redis_*`, `redis_cache_*` or `redis_persistent_*` variables respectively.

For required variables they need to be set for each Redis service you are provisioning:

- `elasticache_redis_instance_type` - The [AWS Instance Type](https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/CacheNodes.SupportedTypes.html) of the Redis instance to use without the `cache.` prefix. For example, to use a `cache.m5.2xlarge` Elasticache instance type, the value of this variable should be `m5.2xlarge`. **Required**.
  - `elasticache_redis_cache_instance_type` or `elasticache_redis_persistent_instance_type` when setting up separate services.
- `elasticache_redis_node_count` - The number of replicas of the Redis instance to have for failover purposes. This should be set to at least `2` or higher for HA and `1` if this isn't a requirement. **Required**.
  - `elasticache_redis_cache_node_count` or `elasticache_redis_persistent_node_count` when setting up separate services.

For optional variables they work in a defaults like manner. When configuring for any Redis types the main `elasticache_redis_*` variable can be set once and this will apply to all but you can also additionally override this behavior with specific variables as follows:

- `elasticache_redis_engine_version`  - The version of the Redis instance. Should only be changed to versions that are supported by GitLab. Optional, default is `6.x`.
  - Optionally `elasticache_redis_cache_engine_version` or `elasticache_redis_persistent_engine_version` can be used to override for separate services.
- `elasticache_redis_port` - The port of the Redis instance. Should only be changed if required. Optional, default is `6379`.
  - Optionally `elasticache_redis_cache_port` or `elasticache_redis_persistent_port` can be used to override for separate services.
- `elasticache_redis_multi_az` - Specifies if the Redis instance is multi-AZ. Should only be disabled when HA isn't required. Optional, default is `true`.
  - Optionally `elasticache_redis_cache_multi_az` or `elasticache_redis_persistent_multi_az` can be used to override for separate services.

If deploying a combined Redis setup that contains all queues (5k and lower) the following settings should be set (replacing any previous `redis_*` settings):

As an example, to set up a standard AWS Elasticache Redis service for a [5k](https://docs.gitlab.com/ee/administration/reference_architectures/5k_users.html) environment with the required variables should look like the following in your `environment.tf` file:

```tf
module "gitlab_ref_arch_aws" {
  source = "../../modules/gitlab_ref_arch_aws"

  [...]

  elasticache_redis_node_count = 2
  elasticache_redis_instance_type = "m5.large"
}
```

And for a larger environment, such as a [10k](https://docs.gitlab.com/ee/administration/reference_architectures/10k_users.html), where Redis is separated:

```tf
module "gitlab_ref_arch_aws" {
  source = "../../modules/gitlab_ref_arch_aws"

  [...]

  elasticache_redis_cache_node_count = 2
  elasticache_redis_cache_instance_type = "m5.xlarge"

  elasticache_redis_persistent_node_count = 2
  elasticache_redis_persistent_instance_type = "m5.xlarge"
}
```

Once the variables are set in your file you can proceed to provision the service as normal. Note that this can take several minutes on AWS's side.

Once provisioned you'll see several new outputs at the end of the process. Key from this is the `elasticache_redis*_address` output, which contains the address for the Redis instance that then needs to be passed to Ansible to configure. Take a note of this address for the next step.

### Configuring with Ansible

Configuring GitLab to use non Omnibus Redis instance(s) with Ansible is the same regardless of which cloud provider you choose. All that's required is a few tweaks to your [Environment config file](environment_configure.md#environment-config-varsyml) (`vars.yml`) to point the Toolkit at the Redis instance(s).

It's worth noting this config will also work for custom Redis instance(s) that have been provisioned outside of Omnibus or Cloud Services. Although please note, in this setup it's expected that HA is in place and the URL to connect to the Redis instance(s) never changes.

The variables to set are dependent on if the setup is to have combined or separated Redis queues depending on the target Reference Architecture. The only different is that the prefix of each variable changes depending on what Redis instances you're provisioning - `redis_*`, `redis_cache_*` and `redis_persistent_*` respectively. All of the variables are the same for each instance type and are described once below:

- `redis_host` - The hostname of the Redis instance. Provided in Terraform outputs if provisioned earlier. **Required**.
  - Becomes `redis_cache_host` or `redis_persistent_host` when setting up separate services.
- `redis_port` - The port of the Redis instance. Should only be changed if required. Optional, default is `6379`.
  - Becomes `redis_cache_port` or `redis_persistent_port` when setting up separate services. Will default to `redis_port` if not specified.
- `redis_external_ssl` - Sets GitLab to use SSL connections to the external Redis service. Redis services provisioned by the Toolkit will always use SSL. Should only be changed when using a custom Redis service that doesn't have SSL configured. Optional, default is `true`.

Once set, Ansible can then be run as normal. During the run it will configure the various GitLab components to use the database as well as any additional tasks such as setting up a separate database in the same instance for Praefect.

After Ansible is finished running your environment will now be ready.
