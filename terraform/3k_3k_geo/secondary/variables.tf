variable "project" {
  default = "group-geo-f9c951"
}

variable "credentials_file" {
  default = "../../../secrets/serviceaccount-minimal-ha.json"
}

variable "region" {
  default = "europe-west3"
}

variable "zone" {
  default = "europe-west3-c"
}

variable "prefix" {
  default = "gitlab-qa-3k"
}

variable "machine_image" {
  default = "ubuntu-1804-lts"
}

variable "geo_role" {
  default = "geo-secondary"
}

variable "geo_group" {
  default = "jsl-3k-geo"
}