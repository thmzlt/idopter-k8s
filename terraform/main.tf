terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.66"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.1"
    }
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = var.credentials
}

provider "kubernetes" {
  host                   = google_container_cluster.main.endpoint
  client_certificate     = google_container_cluster.main.master_auth.0.client_certificate
  client_key             = google_container_cluster.main.master_auth.0.client_key
  cluster_ca_certificate = google_container_cluster.main.master_auth.0.cluster_ca_certificate
}

resource "google_compute_network" "main" {
  name                    = "main"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "main" {
  name          = "main"
  region        = var.region
  network       = google_compute_network.main.name
  ip_cidr_range = "10.0.0.0/24"
}

resource "google_container_cluster" "main" {
  name               = "main"
  location           = var.region
  min_master_version = var.k8s_version

  remove_default_node_pool = true
  initial_node_count       = 1
  logging_service          = "none"

  networking_mode = "VPC_NATIVE"
  network         = google_compute_network.main.name
  subnetwork      = google_compute_subnetwork.main.name

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "10.200.0.0/16"
    services_ipv4_cidr_block = "10.100.0.0/16"
  }

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  depends_on = [google_compute_subnetwork.main]
}

resource "google_container_node_pool" "main" {
  name       = "main"
  cluster    = google_container_cluster.main.name
  location   = var.region
  version    = var.k8s_version
  node_count = 1

  node_config {
    oauth_scopes = []

    preemptible  = false
    machine_type = "e2-medium"
    tags         = []

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
