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
  default = "geo-10k-1k-primary"
}

variable "machine_image" {
  default = "ubuntu-1804-lts"
}

variable "external_ip" {
  default = "35.237.219.211"
}

variable "geo_site" {
  default = "geo-primary-site"
}

variable "geo_deployment" {
  default = "geo-10k-1k-test"
}