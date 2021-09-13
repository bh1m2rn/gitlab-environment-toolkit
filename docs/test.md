# GitLab Environment Toolkit Test Suite

To optimizare the review process of the GET contributions, and to improve the quality of the code in this project, we would like to introduce a GET Test Suite to be executed in our CI/CD pipelines in this project.

This test are going to be splitted in two parts, the first regarding the Terraform modules, and the second regarding the Ansible modules.

At the current state we are working on the Terraform part used on AWS.

## Terraform Test

### AWS

Following the modules that we are using in Terraform to interact with AWS.

| Module | Description | Testing |
|---|---|---|
| [gitlab_aws_instance](https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit/-/tree/master/terraform/modules/gitlab_aws_instance) | This module is able to install a generic EC2 instance. | TBD |
| [gitlab_ref_arch_aws](https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit/-/tree/master/terraform/modules/gitlab_ref_arch_aws) | This module is containing the definition of every resource required by the installation, for EC2 based resources it's using the `gitlab_aws_instance` module, passing the required parameters. | TBD |

Following a details of the resources managed by the **gitlab_ref_arch_aws** module.

| File | Description | Using EC2 instance | Hybrid Environment | Testing |
|---|---|:---:|:---:|---|
| consul.tf | | :white_check_mark: | | TBD |
| data.tf | | | |  TBD |
| elastic.tf | | :white_check_mark: | | TBD |
| elasticache.tf | | | | TBD |
| gitaly.tf | | :white_check_mark: | | TBD |
| gitlab_nfs.tf | | :white_check_mark: | | TBD |
| gitlab_rails.tf | | :white_check_mark: | | TBD |
| haproxy.tf | | :white_check_mark: | | TBD |
| kubernetes.tf | | | | TBD |
| monitor.tf | | :white_check_mark: | | TBD |
| networking.tf | | | | TBD |
| pgbouncer.tf | | :white_check_mark: | | TBD |
| postgres.tf | | :white_check_mark: | | TBD |
| praefect_postgres.tf | | :white_check_mark: | | TBD |
| praefect.tf | | :white_check_mark: | | TBD |
| rds.tf | | | | TBD |
| redis.tf | | :white_check_mark: | | TBD |
| security.tf | | | | TBD |
| sidekiq.tf | | :white_check_mark: | | TBD |
| storage.tf | | | | TBD |
| variables.tf | | | | TBD |

### Other Cloud Providers

TBD

## Ansible Test

TBD
