# Building an environment with Geo

* [GitLab Performance Environment Builder - Preparing the toolkit](prep_toolkit.md)
* [GitLab Performance Environment Builder - Building environments](building_environments.md)
* [**GitLab Performance Environment Builder - Building an environment with Geo**](building_geo_environments.md)

With the [toolkit prepared](prep_toolkit.md) you can proceed to building environment(s). Environments are built in two stages: [Provisioning infrastructure via Terraform](#provisioning-environments-infrastructure-with-terraform) and then [Configuring GitLab via Ansible](#configuring-gitlab-on-environments-with-ansible).

[[_TOC_]]

When provisioning environments for Geo there are a few differences to a single environment that need to be made throughout the process to allow the Performance Environment Builder to properly manage the environment:

* Both environments should share the same admin credentials. For example in the case of GCP the same Service Account.
* The GitLab license is shared between the 2 sites. This means the license only needs to be applied to the primary site.

As shown above, for the most part, the process is mostly the same as when creating a single environment and as such the [GitLab Performance Environment Builder - Preparing the toolkit](https://gitlab.com/gitlab-org/quality/performance-environment-builder/-/blob/master/docs/prep_toolkit.md) steps will need to be followed before creating a Geo deployment.

The process used to build the environments follows the documentation for [Geo for multiple nodes](https://docs.gitlab.com/ee/administration/geo/replication/multiple_servers.html). The high level steps that will be followed are:

1. Provision 2 environments with Terraform
    * Each environment will share some common labels to identify them as being part of the same Geo deployment
    * One environment will be identified as being a Primary site and one will be a Secondary
1. Configure the environments with Ansible
    * Each environment will work as a separate environment until Geo is configured
1. Configure Geo on the Primary and Secondary sites

## Terraform

When creating a new Terraform site for Geo it is recommended to create a new sub folder for your Geo deployment with 2 sub folders below that for the primary and secondary config. Although not required this does help to keep all the config for a single Geo project in one location. The two separate environments however will always still need their own folders here for Terraform to manage their State correctly.

```bash
my-geo-site
    ├── primary
    └── secondary
```

After this it is recommended to copy an existing reference architecture for the primary and secondary folders. You could copy the 25k reference architecture to use as your primary site and the 3k for your secondary, or use 5k for both your primary and secondary sites, the Geo process will work for any multi node combination with the same steps.

>Currently 1k and 2k environments are not supported.

The main steps for [Provisioning Environment(s) Infrastructure with Terraform](https://gitlab.com/gitlab-org/quality/performance-environment-builder/-/blob/master/docs/building_environments.md#provisioning-environments-infrastructure-with-terraform) should be followed when creating a new Terraform project.

Once you have copied the desired architecture sizes we will need to modify all the `.tf` files to allow for Geo. The first step is to add 2 new labels to each of our machines to help identify them as belonging to our Geo site and if it is part of the primary or secondary site.

> You do not need to modify the files `firewall.tf`, `main.tf`, `storage.tf` or `variables.tf`. These files do not create new machines and as such do not require labels.

In each of the `.tf` files that need altering there will be a code block identified as a module. In here we add 2 new lines at the end of the module. This needs to be done in both our primary and secondary folders:
<details>
  <summary>Example `consul.tf`</summary>

```terraform
  module "consul" {
    source = "../../modules/gitlab_gcp_instance"

    prefix = "${var.prefix}"
    node_type = "consul"
    node_count = 3

    geo_role = "${var.geo_role}"
    geo_group = "${var.geo_group}"

    machine_type = "n1-highcpu-2"
    machine_image = "${var.machine_image}"
  }

  output "consul" {
    value = module.consul
  }
```

</details>

Next we need to modify the `variables.tf` files to set the 2 new variables.

* `geo_role` is used to identify if a machine belongs to the primary or secondary site.
* `geo_group` is used to identify that a primary and secondary site belong to the same Geo configuration.

It should also be noted that the existing `prefix` variable should still be unique to each Terraform project and shouldn't be shared across a Geo deployment.

<details>
  <summary>Example Primary `variables.tf`</summary>

  ```terraform
    variable "project" {
      default = "<Project ID>"
    }

    variable "credentials_file" {
      default = "<Credentials>"
    }

    variable "region" {
      default = "us-east1"
    }

    variable "zone" {
      default = "us-east1-c"
    }

    variable "prefix" {
      default = "my-10k-environment"
    }

    variable "machine_image" {
      default = "ubuntu-1804-lts"
    }

    variable "external_ip" {
      default = "<external ip>"
    }

    variable "geo_role" {
      default = "geo-primary"
    }

    variable "geo_group" {
      default = "my-geo-site"
    }
  ```

</details>

<details>
  <summary>Example Primary `variables.tf`</summary>

  ```terraform
    variable "project" {
      default = "<Project ID>"
    }

    variable "credentials_file" {
      default = "<Credentials>"
    }

    variable "region" {
      default = "europe-west4"
    }

    variable "zone" {
      default = "europe-west4-a"
    }

    variable "prefix" {
      default = "my-3k-environment"
    }

    variable "machine_image" {
      default = "ubuntu-1804-lts"
    }

    variable "external_ip" {
      default = "<external ip>"
    }

    variable "geo_role" {
      default = "geo-secondary"
    }

    variable "geo_group" {
      default = "my-geo-site"
    }
  ```

</details>

Once each site is configured we can run the `terraform apply` command against each project. You can run this command against the primary and secondary sites at the same time.

### Configuring Postgres on the Secondary site

At the moment [multi-node PostgreSQL](https://docs.gitlab.com/ee/administration/geo/replication/multiple_servers.html#step-2-configure-the-main-read-only-replica-postgresql-database-on-the-secondary-node) is not supported on the secondary site and as such the `node_count` in `postgres.tf` should be set to 1 in the secondary config.

## Ansible

We will need to start by creating new inventories for a Geo deployment. For Geo we will require 3 inventories: `primary`, `secondary` and `all`. It is recommended to store these in one parent folder to keep all the config together.

```bash
my-geo-site
    ├── all
    ├── primary
    └── secondary
```

The primary and secondary folders are treated as normal and as such the steps for [Configuring GitLab on Environment(s) with Ansible](https://gitlab.com/gitlab-org/quality/performance-environment-builder/-/blob/master/docs/building_environments.md#configuring-gitlab-on-environments-with-ansible) should be followed.

To remove the license from the secondary site you can just remove the `gitlab_license_file` setting from the secondary `vars.yml` file.

Once the inventories for primary and secondary are complete you can use Ansible to configure GitLab. Once complete you will have 2 independent instances of GitLab. The primary site should have a license installed and the secondary will not.
As these environments are still separate from each other at this point, they can be built at the same time and are not reliant on each other.

The all inventory is very similar to the primary and secondary, it allows Ansible to see both sites instead of one for the tasks that require coordination across both environments. To create the all inventory files it is easiest to copy them from primary and modify some values as follows:

### `vars.yml`

Add the line `secondary_external_url` which needs to match the `external_url` in the secondary inventory vars file.

### `all.gcp.yml`

Under the `keyed_groups` section add 2 new keys that will configure Ansible to look for the new labels you added with Terraform:

```yaml
- key: labels.gitlab_geo_role
  separator: ''
- key: labels.gitlab_geo_full_role
  separator: ''
```

Under the `filters` section we want to remove the existing filter and replace it with:

```yaml
filters:
  - labels.gitlab_geo_group = my-geo-site
```

The existing filter is based on an environments prefix, this is unique to each environment. The Geo group is how we identify multiple environments to run our Geo configuration against.

Once done we can then run the command
`ansible-playbook -i inventories/my-geo-site/all gitlab-geo.yml`

Once complete the 2 sites will now be connected and have Geo configured.
