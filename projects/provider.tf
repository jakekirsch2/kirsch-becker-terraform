terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.33.0"
    }
  }

  backend "gcs" {
    bucket = "kirsch-becker-tfstate"
    prefix = "terraform"
  }
}

provider "google" {
  project = "kirsch-becker"
  region  = "us-central1"
  zone    = "us-central1-c"
}
