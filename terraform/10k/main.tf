provider "google" {
  credentials = file(var.credentials_file)

  project = var.project
  region  = var.region
  zone    = var.zone
}

terraform {
  backend "gcs" {
    bucket  = "10k-terraform-state"
    credentials = "../../serviceaccount.json"
  }
}