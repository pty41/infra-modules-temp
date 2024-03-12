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

variable "model_views_sa_email" {
  type        = string
  description = "ACM BQ Connector Service Account"
}

locals {
  dataset_list = {
    "test_dataset" : "The testing dataset"
  }
  table_list = {
    "test_table1" : "The testing table1",
    "test_table2" : "The testing table1"
  }
  raw_data_layer_dataset = "test_dataset"
}

# dataset
resource "google_bigquery_dataset" "temp_dataset" {
  for_each      = local.dataset_list
  location      = "EU"
  project       = var.project_id
  dataset_id    = each.key
  friendly_name = each.key
  description   = each.value
}

# tables 
resource "google_bigquery_table" "temp_table" {
  for_each = local.table_list

  project       = var.project_id
  dataset_id    = local.raw_data_layer_dataset
  table_id      = "test_${each.key}"
  friendly_name = "test_${each.key}"
  description   = each.value
  clustering    = ["event_hour", "event_date"]
  time_partitioning {
    type          = "HOUR"
    expiration_ms = 94670856000
  }

  schema = file("schema/${each.key}.json")
}


# service account externel-connector access dataset 
resource "google_bigquery_dataset_iam_member" "dataset_model_views_connection" {
  for_each   = local.dataset_list
  dataset_id = each.key
  member     = "serviceAccount:${var.model_views_sa_email}"
  role       = "roles/bigquery.dataViewer"
  project    = var.project_id
}