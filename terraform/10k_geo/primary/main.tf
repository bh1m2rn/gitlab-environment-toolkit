provider "google" {
  version = "~> 2.20"
  credentials = file(var.credentials_file)

  project = var.project
  region  = var.region
  zone    = var.zone
}

terraform {
  required_version = "= 0.12.18"
  backend "gcs" {
    bucket  = "geo-ash2-10k-terraform-state" # TODO: CHANGEME
    prefix  = "primary"
    credentials = "../../../secrets/group-geo-f9c951-b5620cc0bf35.json"
  }
}
