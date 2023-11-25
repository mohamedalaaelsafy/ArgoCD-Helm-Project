# #===============================================================================================
# # Provider for GKE cluster 
# #===============================================================================================


# #===============================================================================================
# # Create Namespaces
# #===============================================================================================
# resource "kubernetes_namespace" "namespaces" {
#   count    = var.install_namespaces ? length(var.namespaces) : 0
#   provider = kubernetes
#   metadata {
#     name = var.namespaces[count.index]
#   }
# }

# #===============================================================================================
# # Installing argocd
# #===============================================================================================
# # DOWNLOAD THE ARGOCD MANIFEST
# data "http" "argocd_file" {
#   url = "https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
# }

# # SAVE THE ARGOCD MANIFEST
# data "kubectl_file_documents" "argocd_file_content" {
#   content = data.http.argocd_file.response_body
# }

# # INSTALL ARGOCD
# resource "kubectl_manifest" "argocd" {
#   for_each           = data.kubectl_file_documents.argocd_file_content.manifests
#   yaml_body          = each.value
#   override_namespace = var.argocd_namespace
#   depends_on         = [data.kubectl_file_documents.argocd_file_content]
# }

# # AUTHENTICATE PRIVATE REPOSETORY
# resource "kubectl_manifest" "argocd-secret" {
#   yaml_body          = file(var.argocd_secret)
#   override_namespace = var.argocd_namespace
# }

# # REPLACE THE DEFAULT CONFIG MAP
# resource "kubectl_manifest" "argocd-config_map" {
#   yaml_body          = file(var.argocd_cm)
#   override_namespace = var.argocd_namespace
# }

# # CREATE APPLICATION IN ARGOCD
# resource "kubectl_manifest" "argocd-app" {
#   yaml_body          = file(var.argocd_app)
#   override_namespace = var.argocd_namespace
# }