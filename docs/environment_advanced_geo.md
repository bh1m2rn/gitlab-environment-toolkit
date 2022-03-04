# Advanced - Geo

- [GitLab Environment Toolkit - Preparing the environment](environment_prep.md)
- [GitLab Environment Toolkit - Provisioning the environment with Terraform](environment_provision.md)
- [GitLab Environment Toolkit - Configuring the environment with Ansible](environment_configure.md)
- [GitLab Environment Toolkit - Advanced - Cloud Native Hybrid](environment_advanced_hybrid.md)
- [GitLab Environment Toolkit - Advanced - External SSL](environment_advanced_ssl.md)
- [GitLab Environment Toolkit - Advanced - Network Setup](environment_advanced_network.md)
- [GitLab Environment Toolkit - Advanced - Component Cloud Services / Custom (Load Balancers, PostgreSQL, Redis)](environment_advanced_services.md)
- [**GitLab Environment Toolkit - Advanced - Geo**](environment_advanced_geo.md)
- [GitLab Environment Toolkit - Advanced - Custom Config / Tasks, Data Disks, Advanced Search and more](environment_advanced.md)
- [GitLab Environment Toolkit - Upgrade Notes](environment_upgrades.md)
- [GitLab Environment Toolkit - Legacy Setups](environment_legacy.md)
- [GitLab Environment Toolkit - Considerations After Deployment - Backups, Security](environment_post_considerations.md)

The Toolkit supports the provisioning and configuration of [GitLab Geo](https://about.gitlab.com/solutions/geo/), where multiple secondary environments can be set up as replicas of the primary for more distributed setups.

On this page we'll detail how to setup Geo. We recommend you only do these setups if you have a good working knowledge of both the Toolkit and what the specific setups involve.

[[_TOC_]]

## Creating a Geo Deployment

When provisioning a Geo deployment there are a few differences to a single environment that need to be made throughout the process to allow the Toolkit to properly manage the deployment:

- Both environments should share the same admin credentials. For example in the case of GCP the same Service Account.
- The GitLab license is shared between the 2 sites. This means the license only needs to be applied to the primary site.

As shown above, for the most part, the process is the same as when creating a single environment and as such the standard Toolkit steps defined in the earlier docs must be followed before creating a Geo deployment.

The process used to build the environments follows the documentation for [Geo for multiple nodes](https://docs.gitlab.com/ee/administration/geo/replication/multiple_servers.html). The high level steps that will be followed are:

1. Provision 2 environments with Terraform
    - Each environment will share some common labels to identify them as being part of the same Geo deployment
    - Each environment will be identified with a unique site name
1. Configure the environments with Ansible
    - Each environment will work as a separate environment until Geo is configured
1. Configure Geo on the Primary and Secondary sites
    - One environment will be identified as being a Primary site and one will be a Secondary

### Terraform

When creating a new Terraform site for Geo it is recommended to create a new subfolder for your Geo deployment with 2 sub-folders below that for each Geo sites config. Although not required this does help to keep all the config for a single Geo deployment in one location. The 2 separate environments however will always still need their own folders here for Terraform to manage their State correctly.

```bash
my-geo-deployment
    ├── site1
    └── site2
```

After this it is recommended to copy an existing reference architecture for each sites folders. You could copy the 25k reference architecture to use as your primary site and the 3k for your secondary, or use 5k for both your primary and secondary sites, the Geo process will work for any combination with the same steps.

The main steps for [GitLab Environment Toolkit - Building environments](environment_provision.md) should be followed when creating a new Terraform project.

Once you have copied the desired architecture sizes we will need to modify them to allow for Geo. The first step is to adjust the `ref_arch` module source variable to point to the right location if you've followed the folder structure above. You will need to add an additional `../` to the path as we are now using sub-folders. For example:

```tf
module "gitlab_ref_arch_*" {
  source = "../../modules/gitlab_ref_arch_*"

  [...]
```

Next you need to add 2 new labels that helps to identify the machines as belonging to our Geo deployment and if they are part of the primary or secondary site:

- `geo_site` - used to identify if a machine belongs to the primary or secondary site. This should be a unique way to identify a site e.g. `london-office`. We recommend avoiding terms like primary and secondary in these site names, this is because the primary and secondary sites can change when performing failover.
- `geo_deployment` - used to identify that primary and secondary sites belong to the same Geo deployment. This must be unique across all Geo deployments that will be stored alongside each other.

The recommended way to do this is to first set them in the `variables.tf` file, for example:

```tf
variable "geo_site" {
    default = "geo-site-london"
}

variable "geo_deployment" {
    default = "my-geo-deployment"
}
```

Next you should add them into the selected cloud providers module's call under `environment.tf`:

```tf
module "gitlab_ref_arch_*" {
  source = "../../modules/gitlab_ref_arch_*"

  geo_site = var.geo_site
  geo_deployment = var.geo_deployment

  [...]
```

:information_source:&nbsp; The configurations above are needed on both the primary and secondary geo sites.

:information_source:&nbsp; When using repmgr on the secondary site the `node_count` in `postgres.tf` should be set to 1 for the secondary sites config. When using Patroni, this can be left at its original value.

Once each site is configured we can run the `terraform apply` command against each project. You can run this command against the primary and secondary sites at the same time.

#### VPC Peering (AWS)

Enabling [AWS VPC Peering](https://docs.aws.amazon.com/vpc/latest/peering/vpc-peering-basics.html) will allow traffic to flow in both directions from a primary and secondary site just like normal internal connections. This is required if the sites are located in different regions.

AWS VPC peering requires a handshake, I.E. A VPC must first request the Peering and the other has to then accept it. As such, this requires Terraform to be run a couple of times to go through this process. To do this first provision the primary site with `terraform apply`, this will output some values that are required by the secondary site to setup peering.

```json
  "network" = {
    "peer_connection_id" = "<peer_connection_id>"
    "vpc_cidr_block" = "<vpc_cidr_block>"
    "vpc_id" = "<vpc_id>"
    "vpc_subnet_priv_ids" =["vpc_subnet_priv_id1", "vpc_subnet_priv_id2"]
    "vpc_subnet_pub_ids" = ["vpc_subnet_pub_id1", "vpc_subnet_pub_id2"]
  }
```

Using this output, add the below values to the secondaries `environment.tf` file. These values are used so that the secondary is able to setup a peering connection with the primary's VPC.

- `peer_region` - The AWS region used for the primary site. This won't be in the output for Terraform but is something that is defined as part of the environment config.
- `peer_vpc_id` - The VPC ID of the primary site.
- `peer_vpc_cidr` - The CIDR used for the internal network as part of the VPC.

:information_source:&nbsp; When setting up VPC peering, the CIDR used for each VPC must be different and cannot overlap.

Now run `terraform apply` for the secondary site and once this completes the `vpc_connection_details` will be output similar to the primary, this time take the `peering_id` and `vpc_cidr_block` and add them into the primary sites `environment.tf`

- `peer_connection_id` - The ID of the peer connection created as part of the secondaries `terraform apply`
- `peer_vpc_cidr` - The CIDR used for the internal network as part of the VPC on the secondary site.

Once added you will need to rerun `terraform apply` for the primary site. This will accept the peering request created by the secondary as well as create routing and firewall rules to allow traffic from the secondary VPC. After this, peering will now be configured and allow your sites to communicate internally.

### Ansible

We will need to start by creating new inventories for a Geo deployment. For Geo we will require 3 inventories: 1 for each site and 1 for all sites. It is recommended to store these in one parent folder to keep all the config together.

```bash
ansible
└── environments
    └── my-geo-deployment
        ├── all
        |   ├── files
        |   └── inventory
        ├── site1
        |   ├── files
        |   └── inventory
        └── site2
            ├── files
            └── inventory
```

For Omnibus environments the site folders are treated the same as non Geo environments with the exception of needing 1 new variable:

- `geo_primary_site_group_name`/`geo_secondary_site_group_name`: These should match the `geo_site` that was set in terraform for the site you want to use as a primary/secondary, any `-` should be replaced with `_` as the names are altered when pulled from the cloud provider. Each setting only needs to go into the site that corresponds to its role i.e. primary or secondary.

You can also remove the GitLab license from the sites that will not be set as the primary before running the `ansible-playbook` command. To remove the license from the secondary site you can just remove the `gitlab_license_file` setting from the secondary `vars.yml` file.

Once the new settings are added the steps for [GitLab Environment Toolkit - Configuring the environment with Ansible](environment_configure.md) should be followed for each site.

For Cloud Native Hybrid environments some variables will need to be added to the primary and secondary site `vars.yml` files.

Primary Sites `vars.yml`:

```yml
cloud_native_hybrid_geo: true
cloud_native_hybrid_geo_role: primary
```

Secondary Site `vars.yml`:

```yml
cloud_native_hybrid_geo: true
cloud_native_hybrid_geo_role: secondary
```

Also for Omnibus and Cloud Native Hybrid environments it's required to add a new `keyed_group` to your Dynamic Inventory config file for your chosen cloud provider:

GCP:

```yaml
- key: labels.gitlab_geo_site
    separator: ''
```

AWS:

```yaml
- key: tags.gitlab_geo_site
  separator: ''
```

Azure:

```yaml
- prefix: ''
  separator: ''
  key: tags.gitlab_geo_site | default('ungrouped')
```

Once the inventories for primary and secondary are complete you can use Ansible to configure GitLab. Once complete you will have 2 independent instances of GitLab. The primary site should have a license installed and the secondary will not.
As these environments are still separate from each other at this point, they can be built at the same time and are not reliant on each other. Once complete you should be able to log into each environment before continuing.

The `all` inventory is very similar to the other sites, it allows Ansible to see all the sites instead of one for the tasks that require coordination across all environments. To create the `all` inventory files it is easiest to copy them from the site used as a primary and modify some values as follows:

#### Dynamic Inventory - `all.*.yml`

The Dynamic Inventory file for `all` Geo machines will be almost the same as the normal inventory files except for the following changes:

- The `filters` should be changed to follow the `gitlab_geo_deployment` label / tag. The normal filter is based on an environment's prefix, unique to each environment. The Geo deployment label / tag is how we identify multiple environments to run our Geo configuration against.
- Two new keys should be added to the `keyed_groups` section for the additional `gitlab_geo_site` and `gitlab_geo_full_role` labels / tags respectively. `gitlab_geo_full_role` is a label / tag that is created for us by the Terraform module, this label is a combination of `geo_site`, `node_type` and `node_level`. Using this we can get the IP of a machine directly by its role in a Geo deployment from a single label.

Dynamic Inventories differ slightly based on Cloud Provider. Below are full examples of Geo `all` Dynamic Inventory files for each Cloud Provider:

GCP:

```yaml
plugin: gcp_compute
projects:
  - <gcp_project_id>
filters:
  - labels.gitlab_geo_deployment = my-geo-deployment
keyed_groups:
  - key: labels.gitlab_node_type
    separator: ''
  - key: labels.gitlab_node_level
    separator: ''
  - key: labels.gitlab_geo_site
    separator: ''
  - key: labels.gitlab_geo_full_role
    separator: ''
scopes:
  - https://www.googleapis.com/auth/compute
hostnames:
  # List host by name instead of the default public ip
  - name
compose:
  # Set an inventory parameter to use the Public IP address to connect to the host
  # For Private ip use "networkInterfaces[0].networkIP"
  ansible_host: networkInterfaces[0].accessConfigs[0].natIP
```

AWS:

```yaml
plugin: aws_ec2
regions:
  - us-east-1
filters:
  tag:gitlab_geo_deployment: my-geo-deployment
keyed_groups:
  - key: tags.gitlab_node_type
    separator: ''
  - key: tags.gitlab_node_level
    separator: ''
  - key: tags.gitlab_geo_site
    separator: ''
  - key: tags.gitlab_geo_full_role
    separator: ''
hostnames:
  # List host by name instead of the default public ip
  - tag:Name
compose:
  # Use the public IP address to connect to the host
  # (note: this does not modify inventory_hostname, which is set via I(hostnames))
  ansible_host: public_ip_address
```

Azure:

```yml
plugin: azure.azcollection.azure_rm

include_vm_resource_groups:
  - "<resource_group_name>"

keyed_groups:
  - prefix: ''
    separator: ''
    key: tags.gitlab_node_type | default('ungrouped')
  - prefix: ''
    separator: ''
    key: tags.gitlab_node_level | default('ungrouped')
  - prefix: ''
    separator: ''
    key: tags.gitlab_geo_site | default('ungrouped')
  - prefix: ''
    separator: ''
    key: tags.gitlab_geo_full_role | default('ungrouped')
```

#### Environment config - `vars.yml`

Add the line `secondary_external_url` which needs to match the `external_url` for the secondary sites inventory vars file.

You can also remove the properties: `prefix`, `gitlab_license_file` and any password vars with the exception of `postgres_password` which is still required. These are not used when configuring Geo and as such should only be set in the individual site inventories.

Next we need to define which site will be used as the primary and which will be a secondary, for this we have the below variables that can be configured:

- `geo_primary_site_group_name`/`geo_secondary_site_group_name`: These should match the `geo_site` that was set in terraform for the site you want to use as a primary/secondary, any `-` should be replaced with `_` as the names are altered when pulled from the cloud provider.
- `geo_primary_site_name`/`geo_secondary_site_name`: This is will be used to identify the sites in the Geo Settings UI. This can be set to any string value.

For Cloud Native Hybrid environments you will need to leave some of the password variables in the `vars.yml` file as well as adding some Geo specific variables:

```yml
# Geo Settings
cloud_native_hybrid_geo: true
geo_primary_site_prefix: "<geo_primary_site_prefix>"
geo_secondary_site_prefix: "<geo_secondary_site_prefix>"

# GCP Specific Settings
geo_primary_site_gcp_project: "<geo_primary_site_gcp_project>"
geo_primary_site_gcp_zone: "<geo_primary_site_gcp_zone>"
geo_secondary_site_gcp_project: "<geo_secondary_site_gcp_project>"
geo_secondary_site_gcp_zone: "<geo_secondary_site_gcp_zone>"

# AWS Specific Settings
geo_primary_site_aws_region: "<geo_primary_site_aws_region>"
geo_secondary_site_aws_region: "<geo_secondary_site_aws_region>"

# Passwords / Secrets
gitlab_root_password: '<gitlab_root_password>'
postgres_password: '<postgres_password>'
redis_password: '<redis_password>'
praefect_external_token: '<praefect_external_token>'
gitaly_token: '<gitaly_token>'
grafana_password: '<grafana_password>'
```

Once done we can then run the command `ansible-playbook -i environments/my-geo-deployment/inventory/all playbooks/gitlab-geo.yml`.

Once complete the 2 sites will now be part of the same Geo deployment.

## Geo Proxying for Secondary Sites

> The Geo Proxying for Secondary Sites is only available for deployments using GitLab versions 14.6 or above.

Before using [Geo Proxying for Secondary Sites](https://docs.gitlab.com/ee/administration/geo/secondary_proxy/index.html) it is recommended to read the current documentation on this feature within GitLab and to understand the scope and limitations of this feature.

To use a single unified URL to access the primary and secondary sites with the Toolkit you will first need to change a few settings within your inventories to enable this feature.

```yaml
# Must be set within the all inventory.
external_url: "<Unified URL>"
secondary_external_url: "<Unified URL>"
geo_primary_internal_url: "<Unique URL for the primary site>"
geo_secondary_internal_url: "<Unique URL for the secondary site>"
```

Although not required, if you want to disable the Geo proxying feature you can set `geo_disable_secondary_proxying: true` in both your primary and secondary inventories. This doesn't need to be disabled if you're not planning on using secondary proxying, this only needs to be set if you want to disable the feature entirely.

## Failover and Recovery

### Failover

> The Toolkit automated Geo failover process is available for Geo deployments running GitLab versions 14.2 or above.

The Toolkit provides the ability to failover from a Geo primary site to a secondary site. This process will disable the current primary site and promotes the secondary site to be a standalone GitLab instance.

Before running the failover process you should ensure you have read and completed any required steps outlined in the [Disaster recovery for planned failover](https://docs.gitlab.com/ee/administration/geo/disaster_recovery/planned_failover.html) documentation.

Once you get to the [Promote the secondary node](https://docs.gitlab.com/ee/administration/geo/disaster_recovery/planned_failover.html#promote-the-secondary-node) step in the documentation you can proceed to perform a failover. To do the failover you can use the existing `all` inventory to disable the primary and promote the secondary in a single command `ansible-playbook -i environments/my-geo-deployment/inventory/all playbooks/gitlab-geo-failover.yml`

After failover has occurred it's important to update your inventories to reflect the new roles they now perform and to avoid misconfiguration on subsequent runs. The original primary and secondary inventories need updating. For a cloud native hybrid environment you will need to update the `cloud_native_hybrid_geo_role` variable to reflect the sites new role. For all environment types you will need to update the `geo_primary_site_group_name`/`geo_secondary_site_group_name` also.

All environment types will need the `all` inventory to be updated, the following variables should be updated to reflect the newly promoted/demoted sites.

- `external_url`/`secondary_external_url`
- `geo_primary_site_group_name`/`geo_secondary_site_group_name`
- `geo_primary_site_name`/`geo_secondary_site_name`

Finally in the Terraform config for the original secondary site you will need to remove the `rds_postgres_replication_database_arn` variable to prevent any misconfiguration happening on the next Terraform run.

### Recovery

After a failover has been performed it's then possible to take the old Geo primary site and turn it into a secondary. This will attach the old primary to the new primary site and begin the replication process. For a planned failover this could occur as soon as the new primary has been promoted, for an unplanned failover the old primary site should be checked for any issues before performing this step.

Before performing a recovery the `all` inventory must be updated to reflect each site's new roles. The below settings should all be updated to point to the new primary and secondary sites.

- `external_url`/`secondary_external_url`
- `geo_primary_site_group_name`/`geo_secondary_site_group_name`
- `geo_primary_site_name`/`geo_secondary_site_name`

Once done you can perform the recovery process by running the command `ansible-playbook -i environments/my-geo-deployment/inventory/all playbooks/gitlab-geo-recovery.yml`

### AWS RDS

The failover and recovery process when using RDS is largely the same as the non RDS process. However it will also require the use of Terraform.

:information_source:&nbsp; Before running `terraform apply` it is advised to check the output of `terraform plan` and ensure that all changes are expected.

#### Failover

To perform a failover the following terraform settings will need to be updated for the site that will be promoted:

- Set `rds_postgres_replication_database_arn` to `null`.
- Set `rds_postgres_password` to your Postgres password.
- Set `rds_postgres_backup_retention_period` to a value between 0 and 35.

Terraform will complete straight away, however the process can take a few minutes to complete and you will need to wait for AWS to show the database as `Available` before continuing. Once completed, the following additional settings will need to be updated and then the failover process can be followed as normal:

- `postgres_host`
- `geo_secondary_postgres_host`
- `geo_secondary_praefect_postgres_host`
- `geo_tracking_postgres_host`

#### Recovery

The RDS recovery process involves deleting the old primary RDS instance, this is done by removing the `rds_postgres_instance_type` setting from the `environment.tf` file for the site currently being recovered and running `terraform apply`. Once deleted, Add the `rds_postgres_instance_type` setting back into `environment.tf` along with the following settings:

- Set `rds_postgres_replication_database_arn` to the ARN for the new primary site.
- Set `rds_postgres_kms_key_arn` to the KMS key used for the primary site's RDS instance.
- Remove `rds_postgres_password`.
- Remove `rds_postgres_backup_retention_period`.
