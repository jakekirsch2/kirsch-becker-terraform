resource "google_project" "kirsch_becker" {
  name            = "kirsch-becker"
  project_id      = "kirsch-becker"
  org_id          = "533271204219"
  billing_account = "017B88-8C0A65-C8A6AB"
}

locals {
  services = [
    "storage-api.googleapis.com",
    "cloudfunctions.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudscheduler.googleapis.com",
    "iam.googleapis.com",
    "compute.googleapis.com",
    "bigquery.googleapis.com",
    "bigqueryconnection.googleapis.com",
    "container.googleapis.com",
    "composer.googleapis.com"
  ]
}

resource "google_project_service" "services" {
  for_each                   = toset(local.services)
  project                    = google_project.kirsch_becker.project_id
  service                    = each.key
  disable_dependent_services = true
}

resource "google_project_iam_binding" "kirsch_becker" {
  project = google_project.kirsch_becker.project_id
  role    = "roles/owner"

  members = [
    "user:jakekirsch11@gmail.com",
    "serviceAccount:533271204219@cloudbuild.gserviceaccount.com",
    "serviceAccount:${google_project.kirsch_becker.number}-compute@developer.gserviceaccount.com",
    "user:kjamesbecker@gmail.com"
  ]
}


resource "google_storage_bucket" "data_platform_data" {
  name          = "data-platform-data"
  project       = google_project.kirsch_becker.project_id
  location      = "us-central1"
  force_destroy = true
  depends_on    = [google_project_iam_binding.kirsch_becker]
}

resource "google_project_iam_member" "composer-service-agent" {
  project = google_project.kirsch_becker.project_id
  role    = "roles/composer.ServiceAgentV2Ext"
  member  = "serviceAccount:service-${google_project.kirsch_becker.number}@cloudcomposer-accounts.iam.gserviceaccount.com"
}

resource "google_composer_environment" "composer" {
  project = google_project.kirsch_becker.project_id
  name    = "kirsch-data-platform-composer-environment"
  region  = "us-central1"
  config {
    software_config {
      image_version = "composer-2-airflow-2"
    }
  }

  depends_on = [google_project_service.services["composer.googleapis.com"], google_project_iam_member.composer-service-agent]
}


resource "google_artifact_registry_repository" "repositories" {
  project       = google_project.kirsch_becker.project_id
  location      = "us-central1"
  repository_id = "docker-repository"
  format        = "DOCKER"
}