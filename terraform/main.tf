module "network" {
  source           = "./modules/network"
  project_id       = "vodafone-technical-task"
  env              = var.env
  region           = var.region
  vpc_name         = var.vpc_name
  subnet_name      = var.subnet_name
  subnet_cidr      = var.subnet_cidr
  subnet_cidr_sec1 = var.subnet_cidr_sec1
  subnet_cidr_sec2 = var.subnet_cidr_sec2
  alb_ip_enabled   = var.alb_ip_enabled
  alb_ip_name      = var.alb_ip_name
}

module "gke" {
  source                     = "./modules/gke"
  project_id                 = var.project_id
  subnet_name                = module.network.subnet_name
  vpc_name                   = module.network.vpc_name
  cluster_name               = var.cluster_name
  master_node_cidr           = var.master_node_cidr
  subnet_cidr_sec1           = module.network.subnet_cidr_sec1
  subnet_cidr_sec2           = module.network.subnet_cidr_sec2
  cluster_region             = var.cluster_region
  cluster_zones              = var.cluster_zones
  machine_type               = var.machine_type
  nodes_per_zone             = var.nodes_per_zone
  node_locations             = var.node_locations
  master_authorized_networks = var.master_authorized_networks
}


module "gke_auth" {
  source               = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  project_id           = var.project_id
  cluster_name         = var.cluster_name
  location             = var.zone
  use_private_endpoint = false
  depends_on           = [module.gke]
}


provider "kubernetes" {
  cluster_ca_certificate = module.gke_auth.cluster_ca_certificate
  host                   = module.gke_auth.host
  token                  = module.gke_auth.token
  alias                  = "k8s"
}
provider "kubectl" {
  host                   = module.gke_auth.host
  cluster_ca_certificate = module.gke_auth.cluster_ca_certificate
  token                  = module.gke_auth.token
  load_config_file       = false
  alias                  = "kctl"
}



module "k8s-resorces" {
  source     = "./modules/kube-resources"
  providers = {
    kubectl    = kubectl.kctl
    kubernetes = kubernetes.k8s
  }


  install_namespaces = var.install_namespaces
  namespaces         = var.namespaces

  install_argocd   = var.install_argocd
  argocd_namespace = var.argocd_namespace
  argocd_app       = var.argocd_app
  argocd_cm        = var.argocd_cm
  argocd_secret    = var.argocd_secret
  
} 