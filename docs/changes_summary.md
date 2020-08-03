# Changes in files and setup

## Differences in set up instructions for minimal ha Geo setup

* Did not use git-crypt
* Did not use Terraform scripts for jaeger, pgbouncer, sidekiq (separate node), consul+sentinel, gitlab_nfs, monitor

### Authentication file management
Added /secrets folder to .gitignore (store private and public ssh keys here) and did not use git-crypt.  

### Preparing the GCP Project

#### Service Account key (used for interacting with Google Cloud API)

Used existing group-geo project instead of creating a new project (as discussed later, modified naming conventions for when Ansible needs to filter through machines). 

I had an existing service account with the required roles, and stored the already-created GCP key as `secrets/serviceaccount-minimal-ha.json`

#### GCP Storage buckets

Both primary and secondary Geo clusters will use the same bucket (e.g. geo-minimal-ha-terraform-state) but have different prefixes "primary" and "secondary", as denoted by the "prefix" backend setting.

### Provisioning Geo Infrastructure with Terraform

#### File changes and additions

**NOTES ON CHANGES MADE FOR GEO-SETUP: some of these changes are made to 'common' files, and so may cause errors or issues if this branch was used to provision a non-Geo environment. Look for `#GEO` comments.**

In `terraform/modules/gitlab_gcp_instance/variables.tf`:
* `label_secondaries` (used for gitlab_node_level label) was renamed to `label_non_main_nodes` to prevent confusion with Geo concepts of primary and secondary nodes
* Two new label variables to be used by Ansible when configuring Geo nodes:
  * `geo_role` (for gitlab_geo_role label)
  * `shared_prefix` (for gitlab_cluster_name label.  This label is more to help filter VMs within a project with several un-related VMs (such as the group-geo project).

In `haproxy.tf`
* added `geo_role`
* updated source = "../../modules/gitlab_gcp_instance" (added ../ at the beginning)
### Configuring GitLab with Geo on Environment(s) with Ansible

[Ansible](https://docs.ansible.com/ansible/latest/index.html) configures GitLab on an Environment's infrastructure. 

#### File Changes and Additions
* Inventory is found here: `ansible/inventories/geo-HA`
* New role added: `ansible/roles/gitlab-geo`
* New .yml files in `ansible/group_vars/`: geo_role_primary, geo_role_secondary, postgres_main (renamed from postgres_primary to avoid confusion with Geo primary), postgres_other (renamed from postgres_secondary)
* Set postgres version in postgres template
* Changes to `roles/[role]/tasks/main.yml`:
  * Gitaly: commented out "Create Additional Gitaly directories"
  * Gitlab-rails: commented out "Mount GitLab NFS"
  * Postgres: commented out "Debug capture output of 'gitlab-ctl repmgr cluster show'", "Debug show output of 'gitlab-ctl repmgr cluster show'", "Check secondary standby status", "Enable secondary standby"
* New file `ansible/vars/gitlab-geo.yml`, which is where Gitlab license should be pasted (or you can do via UI on primary node before running gitlab-geo playbook)
* Added new playbook `ansible/gitlab-geo.yml`
* Edits to playbook .yml files 
  * all.yml: commented out unneeded playbook imports and added gitlab-geo.yml
  * redis.yml: commented out unused hosts
* Many playbooks are not used for minimal-HA Geo setup
* In `ansible/group_vars/gitlab_rails.yml`, added `gitlab_rails_webserver: 'puma'`

1. Extra steps for gjsl9:
* removed postgresql[version]
* In roles/gitlab-geo/tasks/main.yml, added sidekiq_int_ips_for_pg to geo_postgresql['md5_auth_cidr_addresses']
* In roles/sidekiq/templates/sidekiq.gitlab.rb.j2 changed:
gitlab_rails['db_host'] = '{{ postgres_main_int_ip }}'
gitlab_rails['db_port'] = 5432
gitlab_rails['redis_host'] = '{{ redis_main_int_ip }}'
removed {% for gitaly_other_ip in gitaly_other_int_ip %}
  "storage{{loop.index + 1}}" => { 'gitaly_address' => 'tcp://{{ gitaly_other_ip }}:8075' },
{% endfor %}

### Configuring SSH

Configure SSH after running all playbooks.  Ansible uses port 22 for SSH operations, and these steps will change that port's usage.  Port 2222 will be used for admins to SSH into the machine.
