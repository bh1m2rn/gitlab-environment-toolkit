# Provisioning an environment with Geo

When provisioning environments for Geo there are a few changes that need to be made through out the process to allow the Performance Environment Builder to properly manage the environment. However for the most part the steps are the same as when creating a single environment and as such the [GitLab Performance Environment Builder - Preparing the toolkit](https://gitlab.com/gitlab-org/quality/performance-environment-builder/-/blob/master/docs/prep_toolkit.md) steps will need to be followed before creating a Geo deployment. 
> The only difference required for Geo is that the GitLab license is shared between the 2 sites and as such a License is only required for the primary site. Also the a single service account is required for both environments.



The process used to provision the environments is following the documentation for [Geo for multiple nodes](https://docs.gitlab.com/ee/administration/geo/replication/multiple_servers.html)

The high level steps that the builder will follow are:
  - Provision 2 environments with Terraform
    - Each environment will share some common labels to identify them as being part of the same Geo deployment
    - One environment will be identified as being a Primary site and one will be a Secondary
  -   Build the environments with Ansible
      -   Each environment will work as a separate environment until Geo is configured
  -   Configure Geo on the Primary and Secondary sites

## Terraform

When creating a new Terraform site for geo it is recommended to create a new sub folder for your Geo deployment with 2 sub folders below that for the primary and secondary settings. Although not required this does help to keep all the config for a single geo project in one location. 

```bash
my-geo-site
    ├── primary
    └── secondary
```

After this it is recommended to copy an existing reference architecture for the primary and secondary folders. You could copy the 25k reference architecture to use as your primary site and the 3k for your secondary, or use 1k for both your primary and secondary sites, the Geo process should work for any combination with the same steps.

The main steps for [Provisioning Environment(s) Infrastructure with Terraform](https://gitlab.com/gitlab-org/quality/performance-environment-builder/-/blob/master/docs/building_environments.md#provisioning-environments-infrastructure-with-terraform) should be followed when creating a new terraform project.

Once you have copied the desired architecture sizes we will need to modify all the .tf files to allow for Geo. The first step is to add 2 new labels to each of our machines to help identify it as belonging to our geo site and if it is part of the primary site or secondary.

> You do not need to modify the files firewall.tf, main.tf, storage.tf or variables.tf. These files do not create new machines as such do not require labels.

In each of the .tf files that need altering there will be a code block identified as a module. In here we add 2 new lines at the end of the module. This needs to be done in both our primary and secondary folders:
```terraform
geo_role = "${var.geo_role}"
geo_group = "${var.geo_group}"
```
Next we need to modify the `variables.tf` files to set the 2 new variables.
```terraform
variable "geo_role" {
  default = "geo-primary"
}

variable "geo_group" {
  default = "my-geo-site"
}
```
`geo_role` is used to identify if the machines belongs to the primary or secondary site.
`geo_group` is used to identify that a primary and secondary site belong to the same geo configuration.

It should also be noted that the existing `prefix` variable should still be unique to each terraform project and shouldn't be shared across a geo deployment.

Once each site is configured we can run the `terraform apply` command against each project. You can run this command against the primary and secondary sites at the same time.

### Configuring Postgres on the Secondary site
At the moment [multi-node PostgreSQL](https://docs.gitlab.com/ee/administration/geo/replication/multiple_servers.html#step-2-configure-the-main-read-only-replica-postgresql-database-on-the-secondary-node) is not supported on the secondary site and as such the `node_count` in `postgres.tf` should be set to 1 in the secondary config.

## Ansible

We will need to start by creating new inventories for a geo site. For geo we will require 3 inventories: primary, secondary and all. It is recommended to store these in one parent folder to keep all the config together.
```bash
my-geo-site
    ├── all
    ├── primary
    └── secondary
```
The primary and secondary folders are treated as normal and as such the steps for [Configuring GitLab on Environment(s) with Ansible](https://gitlab.com/gitlab-org/quality/performance-environment-builder/-/blob/master/docs/building_environments.md#configuring-gitlab-on-environments-with-ansible) should be followed.

To remove the license from the secondary site you can just remove the `gitlab_license_file` setting from the secondary `vars.yml` file.

Once the inventories for primary and secondary are complete you can use Ansible to build GitLab. Once complete you will have to independent instances of GitLab. The primary site should have a license installed and the secondary will not.
As these sites are still separate from each other they can be build at the same time and are not reliant on each other.

The all inventory is very similar to the primary and secondary, we will just allow Ansible to find both sites instead of one. To create the all inventory files it is easiest to copy them from primary and modify some values. 

### vars.yml
Add the line `secondary_external_url` which needs to match the `external_url` in the secondary inventory vars file.

### all.gcp.yml
Under the `keyed_groups` section add 2 new keys.
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

Once done we can then run the command
`ansible-playbook -i inventories/my-geo-site/all gitlab-geo.yml` 

Once complete the 2 sites will now be connected and have Geo configured.