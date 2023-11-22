resource "google_compute_global_address" "global_alb_ip" {
  count        = var.alb_ip_enabled ? 1 : 0
  name         = var.alb_ip_name
  address_type = "EXTERNAL"
  provisioner "local-exec" {
    command = "echo ${self.address} > ./scripts/ips.txt && bash ./scripts/set-dns.sh"
  }
}
