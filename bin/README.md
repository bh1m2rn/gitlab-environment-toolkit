# GitLab Environment Toolkit CLI

The `bin/get` script aims to provide a command-line interface to the GitLab Environment Toolkit. It is currently in pre-alpha development, and therefore is very limited in functionality. The following documentation represents a potential roadmap; not all features have been (or will be) implemented, and the documentation may inaccurate/out-of-date as things change. This script is neither supported nor recommended for production environments. USE AT YOUR OWN RISK.

## Overview

The `get` script manages the configuration files that define a GitLab environment, provisions cloud infrastructure resources, configures system settings, and deploys the GitLab application.

1. `get init` - initialize the local project environment, check/install pre-requisites
1. `get environment` - manages the local configuration files which define an environment
1. `get provision` - executes terraform to provision the infrastructure for an environment
1. `get configure` - utilizes ansible to configure the application
1. `get upgrade` - trigger a zero-downtime upgrade deployment

## Init

`get init` will check that the local system has supported versions of ansible, python, and terraform available, then attempt to install some pre-requisite packages and ansible roles.

```
get init

Checking local environment...
  python >= 3.9 installed... OK
  ansible >= 2.11 installed... OK
  terraform >= 1.0 installed... OK

Installing python packages...
  google-auth... OK
  requests... OK
  netaddr... OK
  boto3... OK
  botocore... OK
  openshift... OK

Installing ansible roles...
  cloudalchemy.node_exporter... OK
  geerlingguy.docker... OK
  geerlingguy.swap... OK
```

## Environment

`get environment ...` commands allow the user to manage environment definitions.

```
Usage:
  get environment [COMMAND] [options]  
  
  Subcommands:  
    copy,cp     Create a copy of an environment with a new name  
    create      Create a new environment  
    delete,rm   Delete an environment  
    rename,mv   Rename (move) an environment  
    show        Show environment configuration attributes  
    update      Update an environment configuration  
    validate    Validate configuration for an environment  
```

### Create

```
Usage:
  get environment create [OPTIONS] NAME

  Options:
  --size,-s      Specify the reference architecture size for the environment. Allowed values are: 1k,2k,3k,5k,10k,25k,50k
  --provider,-p  Specify which cloud provider will be used for the environment

  --help,-h      Display this help message
```

### Update

### Copy

### Rename/Move

### Validate

### Delete
