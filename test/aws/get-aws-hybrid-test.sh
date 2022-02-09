#!/bin/bash

while getopts ":sthdf" opt; do
  case $opt in
    s)
      echo "Skipping environment generation"
      SKIP_GEN=true >&2
      ;;
    t)
      echo "Performing only test suite"
      TEST_ONLY=true >&2
      ;;
    h)
      echo "Without any options a full environment will be created and tests performed against it."
      echo ""
      echo "You can use one of the following options to customise:"
      echo ""
      echo "-s - Skip the Terraform environment provisioning - Only Ansible configuration and test will be performed."
      echo "-t - Skip the Terraform provisioning and the Ansible configuration - Only the test itself will be performed."
      echo "-d - The test will be executed in debug mode."
      echo "-f - Fetch the credentials from Ansible configuration file to access the test environment."
      echo ""
      exit
      ;;
    d)
      echo "The test will be performed in debug mode"
      QA_DEBUG=true
      ;;
    f)
      echo "Following the parameters from Ansible"
      ROOT_PSW=$(egrep -o "gitlab_root_password:.*" ../../ansible/environments/$2/inventory/vars.yml | cut -d\' -f2)
      echo "Root Password: $ROOT_PSW"
      TARGET_URL=$(egrep -oE "(http|https|ftp):[\/]{2}([a-zA-Z0-9\-\.-]+\.){1,3}[a-zA-Z]+" ../../ansible/environments/$2/inventory/vars.yml)
      echo "Target: $TARGET_URL"
      exit
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

INITPATH=$(pwd)
TESTPATH=$(cd ${INITPATH}/../; pwd)
MAINPATH=$(cd ${INITPATH}/../../; pwd)
TFENVPATH=$(cd ${MAINPATH}/terraform/environments; pwd)
ANSENVPATH=$(cd ${MAINPATH}/ansible/environments; pwd)

PRIVKEY="get-aws-test-rsa"

echo "## GitLab Environment Toolkit - Test Suite - AWS Version ##"
echo ""
echo "This script will guide you through a Smoke Test performed on a GitLab instance installed on AWS with GitLab Environment Toolkit (GET)."
echo "You can find the documentation regarding how to manually perform an installation here: https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit/-/blob/master/docs"
echo "This tool requires that you have Terraform and Ansible related requirements on your machine. You can find the installation process at the following links:"
echo "- https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit/-/blob/master/docs/environment_provision.md#1-install-terraform"
echo ""

# Prefix
echo "Please insert your testing environment prefix"
read ENV_SHORT_NAME

# Version
echo "Please insert the GitLab version that you desire"
read GITLAB_VERSION

# AWS Credentials
echo "Please insert your 'AWS_ACCESS_KEY_ID' that will be used during the test:"
read AWS_ACCESS_KEY_ID
export $AWS_ACCESS_KEY_ID
echo "Please insert your 'AWS_SECRET_ACCESS_KEY' that will be used during the test:"
read AWS_SECRET_ACCESS_KEY
export $AWS_SECRET_ACCESS_KEY

if [ "$TEST_ONLY" != true ] ; then

  if [ "$SKIP_GEN" = true ] ; then

    echo "Skipping env gen..."
    cd ../../

  else

    echo "Please insert the region where the test environment will be spinned up"
    read ENV_REGION
    echo "=============================="
    echo ""

    # SSH Key Generation
    mkdir -p ${INITPATH}/keys
    ssh-keygen -f ${INITPATH}/keys/$PRIVKEY -t rsa -b 4096 -N "" -q
    chmod 0600 ${INITPATH}/keys/$PRIVKEY
    chmod 0600 ${INITPATH}/keys/${PRIVKEY}.pub

    # AWS Terraform State Storage
    echo "Create a Terraform State Storage S3 Bucket like described here: https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit/-/blob/master/docs/environment_prep.md#3-setup-terraform-state-storage-aws-s3"
    echo "The name should be \"${ENV_SHORT_NAME}-terraform-cli-state\""
    TS_BUCKET_NAME="${ENV_SHORT_NAME}-terraform-cli-state"
    TS_BUCKET_KEY="key"
    echo "=============================="
    echo ""

    # AWS Static External IP
    echo "Create 2 Static External IP like described here: https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit/-/blob/master/docs/environment_prep.md#4-create-static-external-ip-aws-elastic-ip-allocation"
    echo "Please insert the first External IP Allocation ID"
    read EIP_ALLOC_ID1
    echo "Please insert the second External IP Allocation ID"
    read EIP_ALLOC_ID2
    echo "=============================="
    echo ""

    mkdir -p ${INITPATH}/terraform-test-env
    # Variable Terraform file creation
    cat << EOF >> ${INITPATH}/terraform-test-env/variables.tf
    variable "prefix" {
      default = "$ENV_SHORT_NAME"
    }
    variable "region" {
      default = "$ENV_REGION"
    }
    variable "ssh_public_key_file" {
      default = "../../../keys/${PRIVKEY}.pub"
    }
    variable "external_ip_allocation" {
      default = ["$EIP_ALLOC_ID1","$EIP_ALLOC_ID2"]
    }
EOF

    # Main Terraform file creation
    cat << EOF >> ${INITPATH}/terraform-test-env/main.tf
    terraform {
      backend "s3" {
        bucket = "${TS_BUCKET_NAME}"
        key = "${TS_BUCKET_KEY}"
        region = "$ENV_REGION"
      }
      required_providers {
        aws = {
          source = "hashicorp/aws"
          version = "~> 3"
        }
      }
    }
    
    provider "aws" {
      region = var.region
    }
EOF

    # Architecture choice
    echo "Choose between one of the following architectures: (type the name):"
    cd ${TESTPATH}/ref-archs
    find . -type f -name '*.tf' | cut -d\/ -f2 | cut -d\. -f1 | awk '{ print "- "$1}'
    read REF_ARCH
    cp ${TESTPATH}/ref-archs/${REF_ARCH}.tf ${INITPATH}/terraform-test-env/environment.tf
    cd ${INITPATH}
    echo "=============================="
    echo ""

    # Creating test env for Terraform
    cp -r ${INITPATH}/keys ${MAINPATH}/
    cp -r ${INITPATH}/terraform-test-env ${TFENVPATH}/$ENV_SHORT_NAME

    echo "Terraform Test environment created!"
    echo "=============================="
    echo ""

    # Creating Ansible test env local folder
    mkdir -p ${INITPATH}/ansible-test-env/files
    mkdir -p ${INITPATH}/ansible-test-env/inventory

    cat << EOF >> ${INITPATH}/ansible-test-env/inventory/${ENV_SHORT_NAME}.aws_ec2.yml
    plugin: aws_ec2
    regions:
      - $ENV_REGION
    filters:
      tag:gitlab_node_prefix: $ENV_SHORT_NAME
    keyed_groups:
      - key: tags.gitlab_node_type
        separator: ''
      - key: tags.gitlab_node_level
        separator: ''
    hostnames:
      # List host by name instead of the default public ip
      - tag:Name
    compose:
      # Use the public IP address to connect to the host
      # (note: this does not modify inventory_hostname, which is set via I(hostnames))
      ansible_host: public_ip_address
EOF

    echo "Please insert the username that will be used for Ansible configuration"
    read SSH_USERNAME
    echo "=============================="
    echo ""

    echo "Please insert the GitLab external url that will be used for Ansible configuration"
    read EXTERNAL_URL
    echo "=============================="
    echo ""

    # Mac OS fix
    export LC_ALL=C

    # Password Generator
    GITLAB_ROOT_PSW=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n1)
    GRAFANA_PSW=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n1)
    PGSQL_PSW=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n1)
    PATRONI_PSW=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n1)
    CONSUL_DB_PSW=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n1)
    GITALY_TOKEN=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n1)
    PGBOUNCER_PSW=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n1)
    REDIS_PSW=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n1)
    PRAEFECT_EXT_TOKEN=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n1)
    PRAEFECT_INT_TOKEN=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n1)
    PRAEFECT_PGSQL_PSW=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n1)

    cat << EOF >> ${INITPATH}/ansible-test-env/inventory/vars.yml
    all:
      vars:
        # Ansible Settings
        ansible_user: "$SSH_USERNAME"
        ansible_ssh_private_key_file: "../../../../keys/${PRIVKEY}"

        # Cloud Settings, available options: gcp, aws, azure
        cloud_provider: "aws"

        # GCP only settings
        # gcp_project: "<gcp_project_id>"
        # gcp_service_account_host_file: "<gcp_service_account_host_file_path>"

        # AWS only settings
        aws_region: "$ENV_REGION"
        aws_allocation_ids: "$EIP_ALLOC_ID1,$EIP_ALLOC_ID2"

        # Azure only settings
        # azure_storage_account_name: "<storage_account_name>"
        # azure_storage_access_key: "<storage_access_key>"

        # General Settings
        prefix: "$ENV_SHORT_NAME"
        external_url: "$EXTERNAL_URL"
        # gitlab_license_file: "<gitlab_license_file_path>"
        gitlab_version: "$GITLAB_VERSION"
        cloud_native_hybrid_environment: true
        kubeconfig_setup: true

        # Component Settings
        patroni_remove_data_directory_on_rewind_failure: false
        patroni_remove_data_directory_on_diverged_timelines: false

        # Passwords / Secrets
        gitlab_root_password: '$GITLAB_ROOT_PSW'
        grafana_password: '$GRAFANA_PSW'
        postgres_password: '$PGSQL_PSW'
        patroni_password: '$PATRONI_PSW'
        consul_database_password: '$CONSUL_DB_PSW'
        gitaly_token: '$GITALY_TOKEN'
        pgbouncer_password: '$PGBOUNCER_PSW'
        redis_password: '$REDIS_PSW'
        praefect_external_token: '$PRAEFECT_EXT_TOKEN'
        praefect_internal_token: '$PRAEFECT_INT_TOKEN'
        praefect_postgres_password: '$PRAEFECT_PGSQL_PSW'
EOF

    cp -r ${INITPATH}/ansible-test-env ${ANSENVPATH}/$ENV_SHORT_NAME

    echo "Running Terraform configuration"
    echo ""

    # Loading ssh key for terraform
    ssh-add ${MAINPATH}/keys/$PRIVKEY

    cd ${TFENVPATH}/$ENV_SHORT_NAME

    terraform init

    terraform apply

  fi

  echo "Running Ansible configuration"
  echo ""

  cd ${ANSENVPATH}/..
  ansible-playbook -i environments/$ENV_SHORT_NAME/inventory playbooks/all.yml

  echo "Environment deployed"

  GITLAB_PASSWORD=$GITLAB_ROOT_PSW

else

  ROOT_PASSWORD=$(egrep -o "gitlab_root_password:.*" ${ANSENVPATH}/${ENV_SHORT_NAME}/inventory/vars.yml | cut -d\' -f2)
  EXTERNAL_URL=$(egrep -oE "(http|https|ftp):[\/]{2}([a-zA-Z0-9\-\.-]+\.){1,3}[a-zA-Z]+" ${ANSENVPATH}/${ENV_SHORT_NAME}/inventory/vars.yml)
  echo "Executing only test against ${EXTERNAL_URL}"

fi

if [ "QA_DEBUG" = "true" ] ; then
  QA_DEBUG=true GITLAB_USERNAME=root GITLAB_PASSWORD=$ROOT_PASSWORD GITLAB_ADMIN_USERNAME=root GITLAB_ADMIN_PASSWORD=$ROOT_PASSWORD gitlab-qa Test::Instance::Smoke EE:${GITLAB_VERSION}-ee $EXTERNAL_URL
else
  GITLAB_USERNAME=root GITLAB_PASSWORD=$ROOT_PASSWORD GITLAB_ADMIN_USERNAME=root GITLAB_ADMIN_PASSWORD=$ROOT_PASSWORD gitlab-qa Test::Instance::Smoke EE:${GITLAB_VERSION}-ee $EXTERNAL_URL
fi

# Cleaning
echo "Do you want to clean the local generated environment files? (y/n)"
read CLEANING
if [ "CLEANING" = "y" ] ; then
  rm -rv ${TESTPATH}/keys
  rm -rv ${TESTPATH}/ansible-test-env
  rm -rv ${TESTPATH}/terraform-test-env
  rm -rv ${MAINPATH}/keys
  rm -rv ${TFENVPATH}/${ENV_SHORT_NAME}
  rm -rv ${ANSENVPATH}/${ENV_SHORT_NAME}
else
  echo "From now, you can use directly the ansible/terraform environment folders and related commands to manage your envs. (Remember to have in your env var the AWS credentials)"
fi
