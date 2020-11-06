variable "project" {
  default = "gitlab-qa-distribution-35632a"
}

variable "credentials_file" {
  default = "../../../keys/distribution/gitlab-qa-distribution-sa.json"
}

variable "region" {
  default = "europe-west4"
}

variable "zone" {
  default = "europe-west4-a"
}

variable "prefix" {
  default = "geo-3k"
}

variable "machine_image" {
  default = "ubuntu-1804-lts"
}

variable "external_ip" {
  default = "34.91.88.231"
}

variable "geo_site" {
  default = "geo-secondary-site"
}

variable "geo_deployment" {
  default = "geo-test"
}