### General ###
project_id = "vodafone-technical-task"

env = "dev"

region = "us-central1"

zone = "us-central1-c"


### NETWORK ###
vpc_name = "argocd"

subnet_name = "argocd-subnet"

subnet_cidr = "10.0.5.0/24"

subnet_cidr_sec1 = "10.6.0.0/16"

subnet_cidr_sec2 = "10.7.0.0/16"

alb_ip_enabled = false

alb_ip_name = ""

### GKE CLUSTER ###
cluster_name = "argocd-cluster"

cluster_region = "us-central1"

cluster_zones = ["us-central1-c"]

node_locations = "us-central1-c" # Locations of Nodes in Node pool

machine_type = "e2-medium"

nodes_per_zone = 1

master_node_cidr = "172.16.0.16/28"

master_authorized_networks = [
  {
    cidr_block   = "0.0.0.0/0"
    display_name = "Allow all"
  }
]

### K8s RESOURCES ####
# install_resorces = true

install_namespaces = true
namespaces         = ["argocd", "shared-services", "dev"]

install_argocd   = true
argocd_namespace = "argocd"
argocd_project   = "manifest-files/argocd/argocd-project.yaml"
argocd_app       = "manifest-files/argocd/argocd-app.yml"
argocd_cm        = "manifest-files/argocd/argocd-cm.yml"
argocd_secret    = "manifest-files/argocd/argocd-secret.yml"