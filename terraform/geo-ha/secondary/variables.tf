variable "project" {
  default = "group-geo-f9c951"
}

variable "credentials_file" {
  default = "../../../secrets/serviceaccount-minimal-ha.json"
}

variable "region" {
  default = "europe-west4"
} # TODO: CHANGEME

variable "zone" {
  default = "europe-west4-a"
} # TODO: CHANGEME

variable "prefix" {
  default = "jslgitaly-sec"
} # TODO: CHANGEME, must start with "shared_prefix"

variable "machine_image" {
  default = "ubuntu-1804-lts"
}

variable "secrets_storage_bucket" {
  default = "jslgitaly-sec-secrets"
} # TODO: CHANGEME

variable "shared_prefix" {
  default = "jslgitaly"
} # TODO: CHANGEME, MUST MATCH ansible/inventories/geo-HA/vars.yml

variable "geo_role" {
  default = "secondary"
}
