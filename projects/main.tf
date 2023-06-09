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
  project                    = "kirsch-becker"
  service                    = each.key
  disable_dependent_services = true
}

resource "google_project_iam_binding" "kirsch_becker" {
  project = "kirsch-becker"
  role    = "roles/owner"

  members = [
    "user:jakekirsch11@gmail.com",
    "serviceAccount:533271204219@cloudbuild.gserviceaccount.com",
    "user:kjamesbecker@gmail.com"
  ]
}

#create airflow service account
resource "google_service_account" "airflow" {
  project      = "kirsch-becker"
  account_id   = "airflow"
  display_name = "airflow"
}

resource "google_project_iam_binding" "editors" {
  project = "kirsch-becker"
  role    = "roles/editor"

  members = [
    "serviceAccount:${google_service_account.airflow.email}",
    "serviceAccount:533271204219@cloudservices.gserviceaccount.com",
    "serviceAccount:533271204219-compute@developer.gserviceaccount.com"
  ]
}

resource "google_storage_bucket" "kirsch_becker_data" {
  name          = "kirsch-becker-data"
  project       = "kirsch-becker"
  location      = "us-central1"
  force_destroy = true
  depends_on    = [google_project_iam_binding.kirsch_becker]
}

resource "google_project_iam_member" "composer-service-agent" {
  project = "kirsch-becker"
  role    = "roles/composer.ServiceAgentV2Ext"
  member  = "serviceAccount:service-533271204219@cloudcomposer-accounts.iam.gserviceaccount.com"
  depends_on = [google_project_service.services["composer.googleapis.com"]]
}

resource "google_composer_environment" "composer" {
  project = "kirsch-becker"
  name    = "kirsch-becker-composer-environment"
  region  = "us-central1"
  config {
    software_config {
      image_version = "composer-2-airflow-2"
    }
    workloads_config {
      scheduler {
        cpu        = 0.5
        memory_gb  = 1.875
        storage_gb = 1
        count      = 1
      }
      web_server {
        cpu        = 0.5
        memory_gb  = 1.875
        storage_gb = 1
      }
      worker {
        cpu = 0.5
        memory_gb  = 1.875
        storage_gb = 1
        min_count  = 1
        max_count  = 3
      }


    }
  }

  depends_on = [google_project_service.services["composer.googleapis.com"],
  google_project_iam_member.composer-service-agent]
}


resource "google_artifact_registry_repository" "repositories" {
  project       = "kirsch-becker"
  location      = "us-central1"
  repository_id = "docker-repository"
  format        = "DOCKER"
  depends_on    = [google_project_service.services["artifactregistry.googleapis.com"]]
}