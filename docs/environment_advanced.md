# Advanced environment setups

---
<table>
    <tr>
        <td><img src="https://gitlab.com/uploads/-/system/project/avatar/1304532/infrastructure-avatar.png" alt="Under Construction" width="100"/></td>
        <td>The GitLab Environment Toolkit is in **Beta** (`v1.0.0-beta`) and work is currently under way for its main release. We do not recommend using it for production use at this time.<br/><br/>As such, <b>this documentation is still under construction</b> but we aim to have it completed soon.</td>
    </tr>
</table>

---

- [GitLab Environment Toolkit - Preparing the environment](environment_prep.md)
- [GitLab Environment Toolkit - Provisioning the environment with Terraform](environment_provision.md)
- [GitLab Environment Toolkit - Configuring the environment with Ansible](environment_configure.md)
- [**GitLab Environment Toolkit - Advanced environment setups**](environment_advanced.md)

The Toolkit by default will deploy the latest version of the selected [Reference Architecture](https://docs.gitlab.com/ee/administration/reference_architectures/). However, it can also support other advanced setups such as Geo or different component makeups such as Gitaly Sharded.

On this page we'll detail all of the supported advanced setups you can do with the Toolkit. We recommend you only do these setups if you have a good working knowledge of both the Toolkit and what the specific setups involve.

[[_TOC_]]

## Geo

When provisioning a Geo deployment there are a few differences to a single environment that need to be made throughout the process to allow the Toolkit to properly manage the deployment:

- Both environments should share the same admin credentials. For example in the case of GCP the same Service Account.
- The GitLab license is shared between the 2 sites. This means the license only needs to be applied to the primary site.

As shown above, for the most part, the process is the same as when creating a single environment and as such the standard Toolkit steps defined in the earlier docs must be followed before creating a Geo deployment.

The process used to build the environments follows the documentation for [Geo for multiple nodes](https://docs.gitlab.com/ee/administration/geo/replication/multiple_servers.html). The high level steps that will be followed are:

1. Provision 2 environments with Terraform
    - Each environment will share some common labels to identify them as being part of the same Geo deployment
    - One environment will be identified as being a Primary site and one will be a Secondary
1. Configure the environments with Ansible
    - Each environment will work as a separate environment until Geo is configured
1. Configure Geo on the Primary and Secondary sites

### Terraform

When creating a new Terraform site for Geo it is recommended to create a new subfolder for your Geo deployment with 2 sub-folders below that for the primary and secondary config. Although not required this does help to keep all the config for a single Geo deployment in one location. The 2 separate environments however will always still need their own folders here for Terraform to manage their State correctly.

```bash
my-geo-deployment
    ├── primary
    └── secondary
```

After this it is recommended to copy an existing reference architecture for the primary and secondary folders. You could copy the 25k reference architecture to use as your primary site and the 3k for your secondary, or use 5k for both your primary and secondary sites, the Geo process will work for any combination with the same steps.

The main steps for [GitLab Environment Toolkit - Building environments](environment_provision.md) should be followed when creating a new Terraform project.

Once you have copied the desired architecture sizes we will need to modify them to allow for Geo. The first step is to adjust the `ref_arch` module source variable to point to the right location if you've followed the folder structure above. You will need to add an additional `../` to the path as we are now using sub-folders. For example:

```tf
module "gitlab_ref_arch_gcp" {
  source = "../../modules/gitlab_ref_arch_gcp"

  [...]
```

Next you need to add 2 new labels that helps to identify the machines as belonging to our Geo deployment and if they are part of the primary or secondary site:

- `geo_site` - used to identify if a machine belongs to the primary or secondary site. This should be set to either `geo-primary-site` or `geo-secondary-site`.
- `geo_deployment` - used to identify that a primary and secondary site belong to the same Geo deployment.

The recommended way to do this is to first set them in the `variables.tf` file, for example:

```tf
variable "geo_site" {
    default = "geo-primary-site"
}

variable "geo_deployment" {
    default = "my-geo-deployment"
}
```

Next you should add them into the module's call under `environment.tf`, for example:

```tf
module "gitlab_ref_arch_gcp" {
  source = "../../modules/gitlab_ref_arch_gcp"

  prefix = var.prefix
  project = var.project

  geo_site = var.geo_site
  geo_deployment = var.geo_deployment

  [...]
```

> Alpha support for [multi-node PostgreSQL](https://gitlab.com/groups/gitlab-org/-/epics/2536) with Patroni is currently in development. When using repmgr on the secondary site the `node_count` in `postgres.tf` should be set to 1 for the secondary sites config. When using Patroni, this can be left at its original value.

Once each site is configured we can run the `terraform apply` command against each project. You can run this command against the primary and secondary sites at the same time.

### Ansible

We will need to start by creating new inventories for a Geo deployment. For Geo we will require 3 inventories: `primary`, `secondary` and `all`. It is recommended to store these in one parent folder to keep all the config together.

```bash
my-geo-deployment
    ├── all
    ├── primary
    └── secondary
```

The `primary` and `secondary` folders are treated the same as non Geo environments and as such the steps for [GitLab Environment Toolkit - Configuring the environment with Ansible](environment_configure.md) should be followed, you should remove the GitLab license from the secondary site before running the `ansible-playbook` command. To remove the license from the secondary site you can just remove the `gitlab_license_file` setting from the secondary `vars.yml` file.

Once the inventories for primary and secondary are complete you can use Ansible to configure GitLab. Once complete you will have 2 independent instances of GitLab. The primary site should have a license installed and the secondary will not.
As these environments are still separate from each other at this point, they can be built at the same time and are not reliant on each other. Once complete you should be able to log into each environment before continuing.

The `all` inventory is very similar to the `primary` and `secondary`, it allows Ansible to see both sites instead of one for the tasks that require coordination across both environments. To create the `all` inventory files it is easiest to copy them from `primary` and modify some values as follows:

#### `vars.yml`

Add the line `secondary_external_url` which needs to match the `external_url` in the `secondary` inventory vars file. You can also remove the properties: `cloud_provider`, `prefix`, `gitlab_license_file`, `postgres_replication_manager` and `gitlab_root_password_file`. These are not used when configuring Geo and as such should only be set in the `primary` and `secondary` inventories.

#### `all.gcp.yml`

Under the `keyed_groups` section add 2 new keys that allow Ansible to identify machines based on the Geo deployment and a machines role within that deployment:

```yaml
- key: labels.gitlab_geo_site
  separator: ''
- key: labels.gitlab_geo_full_role
  separator: ''
```

`gitlab_geo_full_role` is a label that is created for us by a Terraform module, this label is a combination of `geo_site`, `node_type` and `node_level`. Using this we can get the IP of a machine directly by its role in a Geo deployment from a single label.

Under the `filters` section we want to remove the existing filter and replace it with:

```yaml
filters:
  - labels.gitlab_geo_deployment = my-geo-deployment
```

The existing filter is based on an environments prefix, this is unique to each environment. The Geo deployment is how we identify multiple environments to run our Geo configuration against.

Once done we can then run the command `ansible-playbook -i inventories/my-geo-deployment/all gitlab-geo.yml`

Once complete the 2 sites will now be part of the same Geo deployment.

## Advanced Search with Elasticsearch

The Toolkit supports automatically setting up GitLab's [Advanced Search](https://docs.gitlab.com/ee/integration/elasticsearch.html) functionality. This includes provisioning and configuring Elasticsearch nodes to be a cluster as well as configuring GitLab to use it.

Note that to be able to enable Advanced Search you'll require at least a GitLab Premium License.

Due to the nature of Elasticsearch it's difficult to give specific guidance on what size and shape the cluster should take as it's heavily dependent on things such as data, expected usage, etc... That being said [we do offer some guidance in our Elasticsearch docs](https://docs.gitlab.com/ee/integration/elasticsearch.html#guidance-on-choosing-optimal-cluster-configuration). For testing our data the Quality team has found a size similar to the Gitaly nodes in each Reference Architecture has sufficed so far.

Enabling Advanced Search on your environment is designed to be as easy possible and can be done as follows:

- Elasticsearch nodes should be provisioned as normal via Terraform.
- Once the nodes are available Ansible will automatically configure them, downloading and setting up the Elasticsearch Docker image.
  - At the time of writing the Elasticsearch version deployed is `7.6.2`. To deploy a different version you can set the `elastic_version`.
- The Toolkit will also setup a Kibana Docker container on the Primary Elasticsearch node for administration and debugging purposes. Kibana will be accessible on your external IP / URL and port `5602` by default, e.g. `http://<external_ip_or_url>:5602`.
- Ansible will then configure the GitLab environment near the end of its run to enable Advanced Search against those nodes and perform the first index.

## Gitaly Sharded

[Gitaly Cluster](https://docs.gitlab.com/ee/administration/gitaly/praefect.html) is recommended in the Reference Architectures from `13.9.0` onwards for its high availability and replication features. Before Cluster Gitaly was configured in a Sharded setup, where there are multiple separate Gitaly nodes that each hosted their own repo data with no HA or replication between them.

The Toolkit supports setting up a Gitaly Sharded setup if desired. This is done simply by not provisioning the Praefect nodes required in Cluster. If these nodes aren't present the Toolkit automatically assumes that the environment is using Gitaly Sharded and will configure in that way.

Note this setup is only valid for new environments. Attempting to switch an environment from using Gitaly Cluster to Sharded and vice versa will break the environment.

## Postgres 11 & Repmgr

Postgres 12 and Patroni are recommended in the Reference Architectures from `13.9.0` onwards. The previous version of Postgres, 11, is still supported in `13.x.y` versions however and the Toolkit supports deploying it.

One of the changes with Postgres 12 was the switch to Patroni over Repmgr as the default replication manager. It's worth noting that Patroni will support a Postgres 11 setup but Repmgr won't support a Postgres 12 one.

Configuring either Postgres 11 or Repmgr can be done as follows:

- Postgres 11 - Set `postgres_version` in the inventory variables to `11`, e.g. `postgres_version: 11`. Patroni or Repmgr can be used here but note the advice below on switching replication managers for existing setups.
- Repmgr - Set the `postgres_replication_manager` inventory variable to `repmgr`. This can only be used with Postgres 11.

Like Gitaly Cluster, this guidance is only for new installs. You must note the following for existing installs:

- Attempting to switch replication manage is only supported *once* from Repmgr to Patroni. Attempting to switch from Patroni to Repmgr will **break the environment irrevocably**.
- [Switching from Postgres 11 to 12 is supported when Patroni is the replication manager](https://docs.gitlab.com/ee/administration/postgresql/replication_and_failover.html#upgrading-postgresql-major-version-in-a-patroni-cluster) but this is a manual process that must be done directly unless on a single 1k installation. Once the upgrade process is done you must remove the `postgres_version` variable from your inventory variables.

## Configure stateful components for a Hybrid Cloud Native Deployment

An alternative supported GitLab environment setup is the 
[Hybrid Cloud Native Deployment](https://docs.gitlab.com/ee/administration/reference_architectures/#configuring-select-components-with-cloud-native-helm). In this setup, _stateless_ components such as GitLab Rails, Sidekiq, and GitLab Shell are shifted to Kubernetes, via our official [Helm charts](https://docs.gitlab.com/charts/) while _stateful_ components continue to be deployed using Omnibus via the Toolkit (as running stateful GitLab components in Kubernetes is _not recommend_ at large scale).

Helm can be viewed as the equivalent of this Toolkit for Kubernetes deployments. The Toolkit can be used to setup all of the stateful components and then Helm for the stateless components. For the former, this is done simply by not provisioning the Rails and Sidekiq nodes (External HAProxy should also be removed as load balancer is done in Kubernetes) with the Toolkit. If these nodes aren't present the Toolkit automatically configure the environment as required. After these are set up, the stateless Webservice (Rails) and Sidekiq pods can be deployed with [Helm](https://docs.gitlab.com/charts/).

The general process in detail for a Hybrid Cloud Native Deployment is as follows:

1. [Provision environment with Terraform](environment_provision.md)
    - Remove Rails, Sidekiq, and External HAProxy nodes `environment.tf`.
    - For optimal performance the stateful and stateless components should all be in the same region/zone.
1. [Configure the stateful components with Ansible](environment_configure.md)
    - Specify `gitlab_shell_token` under the Passwords and Secrets section in the [Environment config file](environment_configure.md#environment-config-varsyml).
      - Note that the passwords set here should be used as part of the Helm setup to create your [GitLab Kubernetes Secrets](https://docs.gitlab.com/charts/installation/secrets.html).
    - [Map the GitLab version in stateful components](environment_configure.md#selecting-what-gitlab-version-to-install) with the [Chart version](https://docs.gitlab.com/charts/installation/version_mappings.html) that will be deployed in the Kubernetes cluster.
1. [Configure the stateless components with Helm](https://docs.gitlab.com/charts/) into Kubernetes. Specific guidance on how to do this, for example on sizing, can be found in the relevant sized Reference Architecture documentation, for example here are the [10k docs](https://docs.gitlab.com/ee/administration/reference_architectures/10k_users.html#cloud-native-deployment-optional).
