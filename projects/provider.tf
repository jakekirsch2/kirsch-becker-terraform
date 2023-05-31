terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.33.0"
    }
  }

  backend "gcs" {
    bucket = "mallak-kirsch-tfstate"
    prefix = "terraform-test"
  }
}

provider "google" {
  project = "mallak-kirsch"
  region  = "us-central1"
  zone    = "us-central1-c"
}
