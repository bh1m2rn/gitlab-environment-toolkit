variable "project" {
  default = "group-geo-f9c951"
}

variable "credentials_file" {
  default = "../../../secrets/group-geo-f9c951-b5620cc0bf35.json"
}

variable "region" {
  default = "us-east1"
}

variable "zone" {
  default = "us-east1-c"
}

variable "geo_role" {
  default = "primary"
}

variable "shared_prefix" {
  default = "geo-ash3-10k" # TODO: CHANGEME
}

variable "prefix" {
  default = "geo-ash3-10k-pri" # TODO: CHANGEME
}

variable "machine_image" {
  default = "ubuntu-1804-lts"
}

# FIXME: Is this in use?
# variable "secrets_storage_bucket" {
#   default = "geo-ash3-10k"-secrets" # TODO: CHANGEME
# }
