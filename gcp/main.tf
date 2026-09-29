terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project = "shop-prod"
  region  = "europe-west1"
}

# --- API: Cloud Run with warm instances --------------------------------------

resource "google_cloud_run_v2_service" "api" {
  name     = "shop-api"
  location = "europe-west1"

  template {
    scaling {
      min_instance_count = 2 # always-warm instances, billed around the clock
      max_instance_count = 20
    }

    containers {
      image = "europe-docker.pkg.dev/shop-prod/app/api:latest"

      resources {
        limits = {
          cpu    = "2"
          memory = "4Gi"
        }
      }
    }
  }
}

# --- Database -----------------------------------------------------------------

resource "google_sql_database_instance" "main" {
  name             = "shop-db"
  region           = "europe-west1"
  database_version = "POSTGRES_16"

  settings {
    tier              = "db-custom-4-16384" # 4 vCPU, 16 GB
    availability_type = "REGIONAL"          # high availability
    disk_size         = 100
    disk_type         = "PD_SSD"
  }
}

# --- Kubernetes: zonal GKE cluster with a node pool ---------------------------

resource "google_container_cluster" "batch" {
  name     = "shop-batch"
  location = "europe-west1-b"

  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "batch" {
  name       = "batch"
  cluster    = google_container_cluster.batch.id
  location   = "europe-west1-b"
  node_count = 3

  node_config {
    machine_type = "n2-standard-4"
    disk_size_gb = 100
  }
}

# --- A standalone VM; priced in the region of its zone -------------------------

resource "google_compute_instance" "ci_runner" {
  name         = "ci-runner"
  machine_type = "e2-standard-4"
  zone         = "europe-west1-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 100
      type  = "pd-balanced"
    }
  }

  network_interface {
    network = "default"
  }
}
