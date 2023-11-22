output "subnet_name" {
  value = google_compute_subnetwork.subnet.name
}

output "subnet_cidr_sec1" {
  value = google_compute_subnetwork.subnet.secondary_ip_range[0].range_name
}
output "subnet_cidr_sec2" {
  value = google_compute_subnetwork.subnet.secondary_ip_range[1].range_name
}
output "vpc_name" {
  value = google_compute_network.vpc.name
}

# output "gs-buckets-sa" {
#   value = module.gs-buckets-sa.email
# }

# output "bigquey-datasets-sa" {
#   value = module.bigquey-datasets-sa.email
# }