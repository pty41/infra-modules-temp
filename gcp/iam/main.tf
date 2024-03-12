terraform {
  required_version = ">= 0.12"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.75.0"
    }
  }
  backend "gcs" {}
}

variable "project_id" {
  type        = string
  description = "project_id"
}

resource "google_service_account" "airflow_connection" {
  project      = var.project_id
  account_id   = "unicron-airflow"
  display_name = "service account for airflow to access the GCP"
}

resource "google_service_account" "externel_connector" {
  project      = var.project_id
  account_id   = "externel-connector"
  display_name = "service account for 3 party to query BQ"
}

resource "google_service_account" "master_feed_connection" {
  project      = var.project_id
  account_id   = "master-feed-connector"
  display_name = "service account for feed management tool to access master feed of GCS bucket"
}

output "connector_sa" {
  value = google_service_account.acm_bqconnector.email
}

output "airflow_connection_sa" {
  value = google_service_account.airflow_connection.email
}

output "master_feed_connection_sa" {
  value = google_service_account.master_feed_connection.email
}