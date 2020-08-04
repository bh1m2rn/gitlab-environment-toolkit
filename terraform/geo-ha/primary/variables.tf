variable "project" {
  default = "group-geo-f9c951"
}

variable "credentials_file" {
  default = "../../../secrets/serviceaccount-minimal-ha.json"
}

variable "region" {
  default = "us-central1"
} # TODO: CHANGEME

variable "zone" {
  default = "us-central1-a"
} # TODO: CHANGEME

variable "prefix" {
  default = "jslgitaly-pri"
} # TODO: CHANGEME

variable "machine_image" {
  default = "ubuntu-1804-lts"
}

variable "secrets_storage_bucket" {
  default = "jslgitaly-pri-secrets"
} # TODO: CHANGEME

variable "shared_prefix" {
  default = "jslgitaly"
} # TODO: CHANGEME, MUST MATCH ansible/inventories/geo-HA/vars.yml

variable "geo_role" {
  default = "primary"
}
