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
variable "env" {
  type        = string
  description = "Name of environment"
}
variable "region" {
  type        = string
  description = "region"
}

variable "airflow_connection_sa_email" {
  type        = string
  description = "Airflow Connection Service Account"
}

variable "master_feed_connection_sa_email" {
  type        = string
  description = "Feed Management Tool Connection Service Account"
}



# storage bucket to receive the data after success process
resource "google_storage_bucket" "airflow_storage" {
  project       = var.project_id
  name          = "${var.env}-airflow-storage"
  location      = var.region
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 365
    }
    action {
      type = "Delete"
    }
  }
}

# storage bucket to receive the data after success process
resource "google_storage_bucket" "master_feed" {
  project       = var.project_id
  name          = "${var.env}-master-feed"
  location      = var.region
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
}

# grant objectOwner and bucketOwner role on kafka_in buckets to platform service account
resource "google_storage_bucket_iam_member" "bucket_iam_airflow_connection" {
  bucket = google_storage_bucket.airflow_storage.name
  for_each = toset([
    "roles/storage.legacyObjectOwner",
    "roles/storage.legacyBucketOwner",
  ])
  role   = each.key
  member = "serviceAccount:${var.airflow_connection_sa_email}"
}

# grant objectViewer role on master_feed buckets to platform service account
resource "google_storage_bucket_iam_member" "master_feed_bucket_iam_connection" {
  bucket = google_storage_bucket.master_feed.name
  for_each = toset([
    "roles/storage.objectViewer",
  ])
  role   = each.key
  member = "serviceAccount:${var.master_feed_connection_sa_email}"
}

# grant objectOwner and bucketOwner role on kafka_in buckets to platform service account
resource "google_storage_bucket_iam_member" "master_feed_bucket_iam_airflow_connection" {
  bucket = google_storage_bucket.master_feed.name
  for_each = toset([
    "roles/storage.legacyObjectOwner",
    "roles/storage.legacyBucketOwner",
  ])
  role   = each.key
  member = "serviceAccount:${var.airflow_connection_sa_email}"
}