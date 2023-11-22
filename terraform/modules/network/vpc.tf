resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "subnet" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_cidr
  region        = "us-central1"
  network       = google_compute_network.vpc.id
  secondary_ip_range {
    range_name    = "sec1"
    ip_cidr_range = var.subnet_cidr_sec1
  }
  secondary_ip_range {
    range_name    = "sec2"
    ip_cidr_range = var.subnet_cidr_sec2
  }
}