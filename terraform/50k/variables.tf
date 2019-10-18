variable "project" {
  default = "gitlab-qa-50k-193234"
}

variable "credentials_file" {
  default = "../../secrets/serviceaccount-50k.json"
}

variable "region" {
  default = "us-east1"
}

variable "zone" {
  default = "us-east1-c"
}

variable "prefix" {
  default = "gitlab-qa-50k"
}

variable "secrets_storage" {
  default = "gitlab-gitlab-qa-50k-secrets"
}
