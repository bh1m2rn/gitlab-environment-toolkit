variable "project" {
  default = "group-geo-f9c951"
}

variable "credentials_file" {
  default = "../../../secrets/serviceaccount-minimal-ha.json"
}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-c"
}

variable "prefix" {
  default = "jsl-3k-geo-secondary"
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

variable "external_ip" {
  default = "34.70.35.217"
}