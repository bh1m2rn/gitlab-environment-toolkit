variable "project" {
  default = "gitlab-qa-distribution-35632a"
}

variable "credentials_file" {
  default = "../../../keys/distribution/gitlab-qa-distribution-sa.json"
}

variable "region" {
  default = "us-east1"
}

variable "zone" {
  default = "us-east1-c"
}

variable "prefix" {
  default = "geo-primary"
}

variable "machine_image" {
  default = "ubuntu-1804-lts"
}

variable "external_ip" {
  default = "34.75.201.220"
}

variable "geo_role" {
  default = "primary"
}
