terraform {
  backend "gcs" {
    bucket = "gitlab-com-get-terraform-state"
    prefix = "gcg"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

