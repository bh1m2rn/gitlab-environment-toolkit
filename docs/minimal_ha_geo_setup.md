# How to create minimal-HA Geo setup

### Preparing the GCP Project

A few steps need to be be performed manually with new GCP projects. The follow should only need to be done once:

#### Service Account key (used for interacting with Google Cloud API)

Used existing group-geo project instead of creating a new project (as discussed later, modified naming conventions for when Ansible needs to filter through machines). 

I had an existing service account with the required roles, and stored the already-created GCP key as `secrets/serviceaccount-minimal-ha.json`

##### Configuring SSH OS Login for Service Account

Need to setup [OS Login](https://www.google.com/search?q=gcp+OS+Login&oq=gcp+OS+Login&aqs=chrome..69i57j69i60.2017j0j1&sourceid=chrome&ie=UTF-8) for the account for SSH access to the created VMs on GCP, which is required by Ansible.

You can enable OS Login as follows:

* Go to the `secrets` folder
* With the `gcloud` command set it to point at your intended project - `gcloud config set project <project-name>` 
**Note: I got warning `Updated property [core/project].  WARNING: You do not appear to have access to project [group-geo-f9c951] or it does not exist.` but everything worked)**
* Now login as the Service Account user via its key created in the last step - `gcloud auth activate-service-account --key-file=serviceaccount-minimal-ha.json`
* Proceed to add the project's public SSH key to the account - `gcloud compute os-login ssh-keys add --key-file=public_ssh_key.pub`
* Finish with switching gcloud back to be logged in as your account `gcloud config set account <account-email-address>`

SSH access should now be enabled on the Service Account and this will be used by Ansible to SSH login each VM. More info on OS Login and how it's configured can be found [here](https://alex.dzyoba.com/blog/gcp-ansible-service-account/).

#### Create GCP Storage buckets

On the intended GCP project create a Storage Bucket for storing the Terraform state. You can name this as you please (starting with a letter) but the name then needs to be set in the environment's `main.tf` as a backend setting.

Both primary and secondary Geo clusters will use the same bucket (e.g. geo-terraform-state) but have different prefixes "primary" and "secondary", as denoted by the "prefix" backend setting.

## Static External IPs (one for primary and one for secondary)

A static external IP is also required to be generated manually outside of Terraform. This will be the main IP for accessing the environment and is required separately due to Terraform needing full control over everything it creates so in the case of a teardown it would destroy this IP and break any DNS entries.

A new IP can be generated via the External IP Addresses (https://console.cloud.google.com/networking/addresses/list?project=group-geo-f9c951) page as required.

Once the newly created IP is found take note of the IP address itself as it will need to be added to the specific `HAProxy` Terraform script as the `external_ips` variable under the `haproxy_external` module.

## DNS Entries

Create a DNS entry (external_url) for each static external IP (https://console.cloud.google.com/net-services/dns/zones?project=group-geo-f9c951)

### Provisioning Geo Infrastructure with Terraform

#### Steps to run Terraform
1. The Terraform directory for provisioning a minimal-HA Geo setup is `terraform/geo-ha`.

1. There are two subdirectories: one for the `primary` node and one for the `secondary` node. You will provision the primary node machines first, and then provision the secondary machines.

1. Change the following variables in the following Terraform script files in both the `primary` and `secondary` directories (tip: search for `TODO: CHANGEME` for values that need to be set.  The `TODO` lines may indicate if the values are cross-referenced elsewhere):
    * `main.tf`: bucket (name in GCP)
    * `variables.tf`: all variables EXCEPT "geo_role"
    * `lb.tf`: google_dns_record_set name and managed_zone (if using Google's load balancer)
    * (check if .terraform directory exists (from previous runs); if so delete)

1. In the environment's Terraform directory (e.g. `terraform/geo-ha/primary`), start by [initializing](https://www.terraform.io/docs/commands/init.html) the environment's Terraform scripts with `terraform init`.

1. You can next optionally run`terraform plan` to view the current state of the environment and what will be changed if you proceed to apply.

1. To apply any changes run `terraform apply` and indicate `yes` when prompted.

    **Warning - running this command will likely apply changes to shared infrastructure. Only run this command if you have permission to do so.**

1. Switch to the `secondary` directory and run the Terraform commands again as above (`init`, `plan`, `apply`). Note: secondary node will have 3 fewer resources than primary because it uses primary's secrets storage bucket, service account and storage bucket iam binding (see `terraform/geo-ha/secondary/storage.tf`)

### Configuring GitLab with Geo on Environment(s) with Ansible

#### Steps to Run Ansible
1. Need to run `all.yml` playbook twice; once for primary, then for secondary. After that, the `gitlab-geo.yml` playbook needs to be run. Some variables need to be set specifically for each node. Look for "# TODO: CHANGEME" in the `ansible/` directory.

1. Prepare:
    * Update `cluster_name` (should be same as `shared_prefix`)
    * Update `shared_prefix` in `ansible/inventories/geo-HA/vars.yml`
    * Make sure all tags are commented out

1.  If you want to install a GitLab version different from the nightly-ee version (which is the default)
    * Export GITLAB_REPO_SCRIPT_URL='https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh'
    * Export GITLAB_REPO_PACKAGE to the desired package, e.g. export GITLAB_REPO_PACKAGE='gitlab-ee=12.9.10-ee.0'
    * Comment out `Update system packages to the latest version` task in ansible/roles/common/tasks/main.yml

1. Before running playbook for primary:
    * Comment out `labels.gitlab_geo_role = "secondary"` in `ansible/inventories/geo-HA/geo-minimal-HA.gcp.yml`
    * Uncomment `labels.gitlab_geo_role = "primary"`
    * Set `external_url` to primary node in `ansible/inventories/geo-HA/vars.yml`.

1. From the `ansible/` directory, use `ansible-playbook` command to run the `all` playbook - `ansible-playbook -i inventories/geo-HA all.yml`.  

1. After first playbook run is complete, before running playbook for secondary:
    * Comment out `labels.gitlab_geo_role = "primary"` in `ansible/inventories/geo-HA/geo-minimal-HA.gcp.yml`
    * Uncomment `labels.gitlab_geo_role = "secondary"`
    * Set `external_url` to secondary node in `ansible/inventories/geo-HA/vars.yml`

1. Run the `all` playbook again - `ansible-playbook -i inventories/geo-HA all.yml`.

1. Before running the `gitlab-geo.yml` playbook:
    * In `ansible/inventories/geo-HA/geo-minimal-HA.gcp.yml`, comment out BOTH `labels.gitlab_geo_role = "primary"` and `labels.gitlab_geo_role = "secondary"`
    * Make sure all tags are commented out

1. Run the `gitlab-geo.yml` playbook - `ansible-playbook -i inventories/geo-HA gitlab-geo.yml`

#### Other Steps I had to do:
1. Disable SSHguard on app nodes (user got locked out load balancer after a few login attempts) 
    * `systemctl stop sshguard`
    * `systemctl disable sshguard`
1. Add HAProxy internal ip to app nodes monitoring whitelist: `gitlab_rails['monitoring_whitelist'] = ['0.0.0.0/0', '10.164.15.215']`

1. Copy SSH keys from Primary Rails 1 to Primary Rails 2 and Secondary Rails 1 and 2. See
https://docs.gitlab.com/ee/administration/geo/replication/configuration.html#step-2-manually-replicate-the-primary-nodes-ssh-host-keys


