variable "project" {
  default = "gitlab-qa-1k-airgapped-"
}

variable "credentials_file" {
  default = "../../secrets/serviceaccount-1k-airgapped-.json"
}

variable "region" {
  default = "us-east1"
}

variable "zone" {
  default = "us-east1-c"
}

variable "prefix" {
  default = "gitlab-qa-1k-airgapped"
}

variable "machine_image" {
  default = "ubuntu-1804-lts"
}

