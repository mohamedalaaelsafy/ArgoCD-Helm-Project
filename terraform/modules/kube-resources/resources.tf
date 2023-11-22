#===============================================================================================
# Authenticate with gke cluster
#===============================================================================================
module "gke_auth" {
  depends_on           = [google_container_cluster.primary, google_container_node_pool.primary_preemptible_nodes]
  source               = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  project_id           = var.project_id
  cluster_name         = google_container_cluster.primary.name
  location             = var.zone
  use_private_endpoint = false
}
# provider "kubernetes" {
#   config_path = "~/.kube/config"
# }
# provider "kubectl" {
#   host                   = module.gke_auth.host
#   cluster_ca_certificate = module.gke_auth.cluster_ca_certificate
#   token                  = module.gke_auth.token
#   load_config_file       = false
# }
#===============================================================================================
# Create Namespaces
#===============================================================================================
resource "kubernetes_namespace" "namespaces" {
  count      = length(var.namespace)
  depends_on = [google_container_cluster.primary, google_container_node_pool.primary_preemptible_nodes, null_resource.get-credentials]
  metadata {
    name = var.namespace[count.index]
  }
}

#===============================================================================================
# Installing Ingress
#===============================================================================================
# NOTE: please add this command #export KUBE_CONFIG_PATH=/path/to/.kube/config
resource "helm_release" "nginx_ingress_controller" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  set {
    name  = "controller.service.loadBalancerIP"
    value = "35.222.249.192"
  }
  depends_on = [kubernetes_namespace.namespaces]
}
#===============================================================================================
# Installing Vault
#===============================================================================================
resource "helm_release" "vault" {
  name             = "vault"
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "vault"
  namespace        = "vault"
  create_namespace = true
  version          = "0.24.0"
  values           = ["${file("./scripts/vault-values.yml")}"]
  depends_on       = [helm_release.nginx_ingress_controller]
  # provisioner "local-exec" {
  #   when = destroy
  #   command = <<-EOT
  #     kubectl -n vault delete persistentvolumeclaim/data-vault-0
  #     EOT
  # }
}

resource "time_sleep" "wait_for_vault" {
  create_duration = "30s"

  depends_on = [helm_release.vault]
}

resource "null_resource" "vault-script" {
  depends_on = [ time_sleep.wait_for_vault ]
  provisioner "local-exec" {
        command = <<-EOT
      ./scripts/vault.sh
      EOT
  }
}

resource "kubectl_manifest" "create_sa" {
  yaml_body          = <<YAML
apiVersion: v1
automountServiceAccountToken: false
kind: ServiceAccount
metadata:
  name: internal-app
  namespace: mentorchief
YAML
  # override_namespace = "mentorchief"
  depends_on         = [null_resource.vault-script]
}


#===============================================================================================
# Installing external-secret-operator
#===============================================================================================
resource "helm_release" "external-secret-operator" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets"
  create_namespace = true
  set {
    name  = "installCRDs"
    value = "true"
  }
  provisioner "local-exec" {
    command = <<-EOT
      ./scripts/eso.sh
      EOT
  }
  depends_on = [kubectl_manifest.create_sa]
}



#===============================================================================================
# Installing argocd
#===============================================================================================
# provider "kubectl" {
#   host                   = module.gke_auth.host
#   cluster_ca_certificate = module.gke_auth.cluster_ca_certificate
#   token                  = module.gke_auth.token
#   load_config_file       = false
# }
data "http" "argocd_file" {
  url = "https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
}
data "kubectl_file_documents" "argocd_file_content" {
  content = data.http.argocd_file.response_body
}
resource "kubectl_manifest" "argocd" {
  for_each           = data.kubectl_file_documents.argocd_file_content.manifests
  yaml_body          = each.value
  override_namespace = "argocd"
  depends_on         = [helm_release.external-secret-operator]
}
resource "kubectl_manifest" "argocd-ingress" {
  yaml_body          = file("./k8s/ingress-argocd.yml")
  override_namespace = "argocd"
  depends_on         = [kubectl_manifest.argocd, helm_release.external-secret-operator]
}

# AUTHENTICATE PRIVATE REPOSETORY
resource "kubectl_manifest" "argocd-secret_private_key" {
  yaml_body          = file("./k8s/argocd-secret.yml")
  override_namespace = "argocd"
  depends_on         = [kubectl_manifest.argocd, helm_release.external-secret-operator]
}
# REPLACE THE DEFAULT CONFIG MAP
resource "kubectl_manifest" "argocd-config_map" {
  yaml_body          = file("./k8s/argocd-cm.yml")
  override_namespace = "argocd"
  depends_on         = [ kubectl_manifest.argocd-secret_private_key ]
}

# CREATE APPLICATION IN ARGOCD
resource "kubectl_manifest" "argocd-app" {
  yaml_body          = file("./k8s/argocd-app.yml")
  override_namespace = "argocd"
  depends_on         = [ kubectl_manifest.argocd-config_map ]
}

# #===============================================================================================
# # Installing prometheus and grafana stack
# #===============================================================================================
# # resource "helm_release" "kube-prometheus-stack" {
# #   name             = "prometheus"
# #   repository       = "https://prometheus-community.github.io/helm-charts"
# #   chart            = "kube-prometheus-stack"
# #   namespace        = "monitoring"
# #   create_namespace = true
# #   depends_on = [google_container_cluster.primary,google_container_node_pool.primary_preemptible_nodes, helm_release.vault]
# # }