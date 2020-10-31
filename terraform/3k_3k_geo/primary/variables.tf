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
  default = "gitlab-qa-3k"
}

variable "machine_image" {
  default = "ubuntu-1804-lts"
}

variable "geo_role" {
  default = "geo-primary"
}

variable "geo_group" {
  default = "jsl-3k-geo"
}

