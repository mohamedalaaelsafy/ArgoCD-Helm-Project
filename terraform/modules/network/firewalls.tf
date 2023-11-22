resource "google_compute_firewall" "firewall" {
  project   = var.project_id
  name      = "${var.env}-allow-iap"
  network   = google_compute_network.vpc.name
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_tags   = null
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["allow-iap"]
}
