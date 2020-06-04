variable "project" {
  default = "gitlab-qa-resources"
}

variable "credentials_file" {
  default = "../../keys/distribution/gitlab-qa-3k-distribution-sa.json"
}

variable "region" {
  default = "us-east1"
}

variable "zone" {
  default = "us-east1-c"
}

variable "prefix" {
  default = "gitlab-qa-3k-distribution"
}

variable "machine_image" {
  default = "ubuntu-1804-lts"
}

