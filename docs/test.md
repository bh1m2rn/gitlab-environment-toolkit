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
| [consul.tf](https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit/-/blob/master/terraform/modules/gitlab_ref_arch_aws/consul.tf) | | :white_check_mark: | :white_check_mark: | TBD |
| [data.tf](https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit/-/blob/master/terraform/modules/gitlab_ref_arch_aws/data.tf) | | | |  TBD |
| [elastic.tf](https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit/-/blob/master/terraform/modules/gitlab_ref_arch_aws/elastic.tf) | | :white_check_mark: | | TBD |
| [elasticache.tf](https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit/-/blob/master/terraform/modules/gitlab_ref_arch_aws/elasticache.tf) | | | | TBD |
| [gitaly.tf](https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit/-/blob/master/terraform/modules/gitlab_ref_arch_aws/gitaly.tf) | | :white_check_mark: | :white_check_mark: | TBD |
| [gitlab_nfs.tf](https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit/-/blob/master/terraform/modules/gitlab_ref_arch_aws/gitlab_nfs.tf) | | :white_check_mark: | :white_check_mark: | TBD |
| [gitlab_rails.tf](https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit/-/blob/master/terraform/modules/gitlab_ref_arch_aws/gitlab_rails.tf) | | :white_check_mark: | | TBD |
| [haproxy.tf](https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit/-/blob/master/terraform/modules/gitlab_ref_arch_aws/haproxy.tf) | | :white_check_mark: | :white_check_mark: | TBD |
| [kubernetes.tf](https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit/-/blob/master/terraform/modules/gitlab_ref_arch_aws/kubernetes.tf) | | | :white_check_mark: | TBD |
| [monitor.tf](https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit/-/blob/master/terraform/modules/gitlab_ref_arch_aws/monitor.tf) | | :white_check_mark: | | TBD |
| [networking.tf](https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit/-/blob/master/terraform/modules/gitlab_ref_arch_aws/networking.tf) | | | :white_check_mark: | TBD |
| [pgbouncer.tf](https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit/-/blob/master/terraform/modules/gitlab_ref_arch_aws/pgbouncer.tf) | | :white_check_mark: | :white_check_mark: | TBD |
| [postgres.tf](https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit/-/blob/master/terraform/modules/gitlab_ref_arch_aws/postgres.tf) | | :white_check_mark: | :white_check_mark: (dismissing) | TBD |
| [praefect_postgres.tf](https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit/-/blob/master/terraform/modules/gitlab_ref_arch_aws/praefect_postgres.tf) | | :white_check_mark: | | TBD |
| [praefect.tf](https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit/-/blob/master/terraform/modules/gitlab_ref_arch_aws/praefect.tf) | | :white_check_mark: | | TBD |
| [rds.tf](https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit/-/blob/master/terraform/modules/gitlab_ref_arch_aws/rds.tf) | | | :white_check_mark: | TBD |
| [redis.tf](https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit/-/blob/master/terraform/modules/gitlab_ref_arch_aws/redis.tf) | | :white_check_mark: | :white_check_mark: | TBD |
| [security.tf](https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit/-/blob/master/terraform/modules/gitlab_ref_arch_aws/security.tf) | | | :white_check_mark: | TBD |
| [sidekiq.tf](https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit/-/blob/master/terraform/modules/gitlab_ref_arch_aws/sidekiq.tf) | | :white_check_mark: | | TBD |
| [storage.tf](https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit/-/blob/master/terraform/modules/gitlab_ref_arch_aws/storage.tf) | | | :white_check_mark: | TBD |
| [variables.tf](https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit/-/blob/master/terraform/modules/gitlab_ref_arch_aws/variables.tf) | | | :white_check_mark: | TBD |

### Other Cloud Providers

TBD

## Ansible Test

TBD
