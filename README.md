# GitLab Performance Environment Builder

Terraform and Ansible tool for building reference HA GitLab environments on Google Cloud Platform (GCP) for performance testing.

## Background

This toolkit is designed to provision and configure GitLab environments, each in their own GCP Project, that match one of our existing or soon to be created [High Availability Reference Architectures](https://docs.gitlab.com/ee/administration/high_availability/README.html#high-availability-architecture-examples)

At the time of writing we have the following environments we are currently building with this toolkit:
* [2k](https://console.cloud.google.com/home/dashboard?project=gitlab-qa-2k-ca9f9e)
* [5k](https://console.cloud.google.com/home/dashboard?project=gitlab-qa-5k-0ee8fa)
* [10k](https://console.cloud.google.com/home/dashboard?project=gitlab-qa-10k-cd77c7)
* [25k](https://console.cloud.google.com/home/dashboard?project=gitlab-qa-25k-bc38fe)
* [50k](https://console.cloud.google.com/home/dashboard?project=gitlab-qa-50k-193234)

The Toolkit consists of two industry leading tools:
* [Terraform](https://www.terraform.io/) - To provision environment infrastructure
* [Ansible](https://docs.ansible.com/ansible/latest/index.html) - To configure GitLab on the provisioned infrastructure

## Initializing the tool

### Configuring [`git-crypt`](https://github.com/AGWA/git-crypt) for authentication

To enable authentication for both Ansible and Terraform several authentication files are provided with the toolkit. These secret files are all encrypted with [`git-crypt`](https://github.com/AGWA/git-crypt) and you'll need to either be added as a trusted user (for local use) or be provided with a symmetric key (for CI use) to unlock these as follows:

#### As a Trusted User (for local use)

To be added as a trusted user you need to generate a [GPG](https://gnupg.org/) key on your machine and send the public part to the Enablement Quality team to be added:

1. [Follow our instructions](https://docs.gitlab.com/ee/user/project/repository/gpg_signed_commits/#generating-a-gpg-key) up to step 11 on how to generate a GPG file and public key.
1. After step 11 you should have your public key in ASCII form. Contact the Enablement Quality team (e.g. on Slack at #qa-performance) where they'll take the key and add you as a trusted user.

After being added as a trusted user, you can checkout this repo and then unlock the secret files with the command `git-crypt unlock`. `git-crypt` will then automatically encrypt and decrypt secrets for you from now on.

#### With a provided symmetric key (CI use)

TBC

### Installing Ansible Dependencies

Ansible requires some dependencies to be installed based on how we use it. You'll need to install python package dependencies on your machine along with some community roles from [Ansible Galaxy](https://galaxy.ansible.com/home) that allow for convenient deployment of some third party applications.

To do this you only have to run the following before running Ansible:

1. `cd` to the `ansible/` directory
1. First install the python packages via `pip install -r requirements/ansible-python-packages.txt`.
    * Note it's expected you already have Python and its package manager pip installed. Additionally you may have the Python3 version of pip installed, `pip3`, and you should replace accordingly.
1. Next, run the following command to install the roles - `ansible-galaxy install -r requirements/ansible-roles.yml`
1. Note that if you're on a Mac OS machine you also need to install `gnu-tar` - `brew install gnu-tar`

### Useful Resources

Each of the tools this toolkit uses need to be installed before using:
* [Terraform Install Guide](https://learn.hashicorp.com/terraform/getting-started/install.html)
  * Make sure to install the specific Terraform version as stated in the environment's `main.tf` file. Terraform requires the version to match for all people using it. Quality team will periodically update this version after testing. Errors will be thrown by Terraform when the install version being used doesn't match what its shared State file expects.
* [Ansible Install Guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

If you are new to any of the tools here it's worth going through the following tutorials for them:
* [Terraform GCP Tutorial](https://learn.hashicorp.com/terraform/gcp/intro)
* [Ansible Tutorial](https://www.guru99.com/ansible-tutorial.html)

## Building the environment

### Preparing the GCP Project

A few steps need to be be performed manually with new GCP projects. The follow should only need to be done once:

#### Service Account key

Each environment will have its own project on GCP. Terraform and Ansible require a [Service Account](https://cloud.google.com/iam/docs/understanding-service-accounts) to be created in each project and the key to be added to this project's secrets folder.

##### Creating the Service Account and key

If this is a new project without a Service Account then you can create one as follows if you're an admin:

* Head to the [Service Accounts](https://console.cloud.google.com/iam-admin/serviceaccounts) page. Be sure to check that the correct project is selected in the dropdown at the top of the page.
* Proceed to create an account with the name `gitlab-qa` and the roles `Compute OS Admin Login` and `Editor`
* On the last page there will be the option to generate a key. Select to do so with the `JSON` format and save it to the `secrets` folder in this project with the naming convention `serviceaccount-<project-name>.json`, e.g. `serviceaccount-10k.json`.  The key file will be automatically encrypted via `git-crypt` as detailed above.
* Finish creating the user

##### Configuring SSH OS Login for Service Account

In addition to creating the Service Account and saving the key we need to also setup [OS Login](https://www.google.com/search?q=gcp+OS+Login&oq=gcp+OS+Login&aqs=chrome..69i57j69i60.2017j0j1&sourceid=chrome&ie=UTF-8) for the account for SSH access to the created VMs on GCP, which is required by Ansible.

For convenience most of the steps required to enable this has already been done. In this project's `secrets/` folder you'd find an SSH key pair, named `gitlab-qa-gcp-ssh`, that is used for all the current project's Service Accounts for login. For a new Service Account you can enable OS Login as follows:

* First head to the `secrets` folder
* With the `gcloud` command set it to point at your intended project - `gcloud config set project <project-name>`
* Now login as the Service Account user via its key created in the last step - `gcloud auth activate-service-account --key-file=serviceaccount-5k.json`
* Proceed to add the project's public SSH key to the account - `gcloud compute os-login ssh-keys add --key-file=gitlab-qa-gcp-ssh.pub`
* Finish with switching gcloud back to be logged in as your account `gcloud config set account <account-email-address>`

SSH access should now be enabled on the Service Account and this will be used by Ansible to SSH login each VM. More info on OS Login and how it's configured can be found [here](https://alex.dzyoba.com/blog/gcp-ansible-service-account/).

#### Grant access to team members

Quality team members (and as others as required) also need to be given access to the project as follows:

* Head to the project's [IAM](https://console.cloud.google.com/iam-admin/iam?supportedpurview=project) page. Be sure to check that the correct project is selected in the dropdown at the top of the page.
* Select to add a new member to the project by clicking `+Add` at the top of the page
* Search for the user by name, select them when found, give them the `Editor` role and then finally save.

#### Get Static External IP

One thing we also need to do is define one external IP manually outside of Terraform that will be used to access the project permanently. This is required due to Terraform needing full control over everything it creates so in the case of a teardown the IP here would also be destroyed and break any DNS entries.

New GCP projects should already have one IP defined by default that we will use for this purpose. If there isn't one then a new IP can be generated via the [External IP Addresses](https://console.cloud.google.com/networking/addresses/list?project=gitlab-qa-25k-bc38fe) page as required.

Once either the default or newly created IP is found take note of the IP address itself as it will need to be added to the specific `HAProxy` Terraform script as the `external_ips` variable under the `haproxy_external` module. You can refer to the existing environment scripts for reference, e.g. as shown [here in the 10k environment's HAProxy script](https://gitlab.com/gitlab-org/quality/performance-environment-builder/blob/master/terraform/10k/haproxy.tf).

### Provisioning Environment(s) Infrastructure with Terraform

[Terraform](https://www.terraform.io/) provisions the Environment's infrastructure. It works in a unique way where each project should have its own folder and State.

>>>
**Terraform keeps a live [state](https://learn.hashicorp.com/terraform/gcp/remote) file of the environment. This is an important part of Terraform as it will refer to this to see what state the intended environment is in at the time of running.**

**To ensure the state is correct for everyone using the tool we store it in the environment's GCP Project under a specific bucket. This should already be configured for the existing projects if not you'll need to ensure the bucket is created in GCP and then configure the respective `main.tf` file accordingly. In addition, Terraform requires everyone to be using the same program version when accessing the state. The specific approved version can also be seen in the respective `main.tf` file.**
>>>

1. Create the environment's Terraform directory and scripts if they don't already exist under `terraform/`. For convenience you should copy one of the existing projects and update the authentication details in the `main.tf` and `variables.tf` files to match the new GCP project.
1. `cd` to the environment's directory under `terraform/`. For this example we'll select the 10k environment - `cd terraform/10k`
1. On the intended GCP project create a Storage Bucket for storing the Terraform state. You can name this as you please but the name then needs to be set in the environment's `main.tf` as a backend setting. For example here is the 10k environment's [main.tf](terraform/10k/main.tf) file with backend config.
1. In the environment's Terraform directory (e.g. `terraform/10k`), start by [initializing](https://www.terraform.io/docs/commands/init.html) the environment's Terraform scripts with `terraform init`.
1. You can next optionally run`terraform plan` to view the current state of the environment and what will be changed if you proceed to apply.
1. To apply any changes run `terraform apply` and select yes
    * **Warning - running this command will likely apply changes to shared infrastructure. Only run this command if you have permission to do so.**

### Configuring GitLab on Environment(s) with Ansible

[Ansible](https://docs.ansible.com/ansible/latest/index.html) configures GitLab on an Environment's infrastructure. 

This is achieved through getting VM info via the [`gcp_compute` Dynamic Inventory source](https://docs.ansible.com/ansible/latest/plugins/inventory/gcp_compute.html) and then running Ansible Playbooks & Roles against each depending on the VM Labels set via Terraform. Unlike Terraform Ansible doesn't require separate folders per Environment but does require a small config directory for each under `ansible/inventories/`

Playbooks & Roles are structured to cover GitLab nodes respectively. E.G. There are playbooks for `gitlab-rails`, `gitaly`, etc... You can see the current list under `ansible/roles/`.

Examples of running Ansible to configure a GitLab instance can be found below. In this example we'll run all playbooks and roles against all nodes via the `all.yml` playbook:

1. `cd` to the `ansible/` directory
1. Create the Environment's inventory config under `ansible/inventories/` if it doesn't exist already. For convenience you should copy one of the existing projects inventories and update all files with the relevant info for the new environment.
1. You then use the `ansible-playbook` command to run the playbook, specifying the intended environment's inventory as well - `ansible-playbook -i inventories/10k all.yml`
    ** If you only want to run a specific playbook & role against the respective VMs you switch out `all.yml` and replace it with the intended playbook, e.g. `gitlab-rails.yml`
