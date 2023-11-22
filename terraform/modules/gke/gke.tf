resource "google_project_service" "gke" {
  project            = var.project_id
  service            = "container.googleapis.com"
  disable_on_destroy = true
}


module "gke" {
  source                          = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version                         = "29.0.0"
  project_id                      = var.project_id
  name                            = var.cluster_name
  region                          = var.cluster_region
  zones                           = var.cluster_zones
  network                         = var.vpc_name
  regional                        = false
  master_ipv4_cidr_block          = var.master_node_cidr
  subnetwork                      = var.subnet_name
  ip_range_pods                   = var.subnet_cidr_sec1
  ip_range_services               = var.subnet_cidr_sec2
  kubernetes_version              = "1.27.3-gke.100"
  release_channel                 = "UNSPECIFIED"
  create_service_account          = false
  http_load_balancing             = true
  remove_default_node_pool        = true
  network_policy                  = false
  horizontal_pod_autoscaling      = false
  enable_vertical_pod_autoscaling = false
  enable_private_nodes            = true
  enable_private_endpoint         = false
  master_authorized_networks      = var.master_authorized_networks
  filestore_csi_driver            = false
  deletion_protection             = false
  # service_account      = module.acr-sa.email
  node_pools = [
    {
      name               = "node-pool"
      machine_type       = var.machine_type
      node_locations     = var.node_locations
      autoscaling        = false
      node_count         = var.nodes_per_zone
      local_ssd_count    = 0
      spot               = false
      disk_size_gb       = 20
      disk_type          = "pd-standard"
      image_type         = "COS_CONTAINERD"
      enable_gcfs        = false
      enable_gvnic       = false
      auto_repair        = false
      auto_upgrade       = false
      preemptible        = false
      initial_node_count = 0
    },
  ]
  # node_pools_tags = { all = [""] }
  depends_on = [google_project_service.gke, module.acr-sa]
}