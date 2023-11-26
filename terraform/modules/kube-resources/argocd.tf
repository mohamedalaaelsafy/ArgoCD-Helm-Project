#===============================================================================================
# Installing argocd
#===============================================================================================
# DOWNLOAD THE ARGOCD MANIFEST
data "http" "argocd_file" {
  count = var.install_argocd ? 1 : 0
  url   = "https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
}

# SAVE THE ARGOCD MANIFEST
data "kubectl_file_documents" "argocd_file_content" {
  count      = var.install_argocd ? 1 : 0
  content    = data.http.argocd_file[0].response_body
  depends_on = [data.http.argocd_file]
}

# INSTALL ARGOCD
resource "kubectl_manifest" "argocd" {

  for_each           = var.install_argocd ? data.kubectl_file_documents.argocd_file_content[0].manifests : {}
  yaml_body          = each.value
  override_namespace = var.argocd_namespace
  depends_on         = [data.kubectl_file_documents.argocd_file_content, data.http.argocd_file]
}

# AUTHENTICATE PRIVATE REPOSETORY
resource "kubectl_manifest" "argocd-secret" {
  count              = var.install_argocd && var.argocd_secret != "" && var.argocd_secret != null ? 1 : 0
  yaml_body          = file(var.argocd_secret)
  override_namespace = var.argocd_namespace
  depends_on         = [kubectl_manifest.argocd, data.http.argocd_file]
}

# REPLACE THE DEFAULT CONFIG MAP
resource "kubectl_manifest" "argocd-config_map" {
  count              = var.install_argocd && var.argocd_cm != "" && var.argocd_cm != null ? 1 : 0
  yaml_body          = file(var.argocd_cm)
  override_namespace = var.argocd_namespace
  depends_on         = [kubectl_manifest.argocd, data.http.argocd_file]
}

# CREATE APPLICATION IN ARGOCD
resource "kubectl_manifest" "argocd-app" {
  count              = var.install_argocd && var.argocd_app != "" && var.argocd_app != null ? 1 : 0
  yaml_body          = file(var.argocd_app)
  override_namespace = var.argocd_namespace
  depends_on         = [kubectl_manifest.argocd, data.http.argocd_file]
}


resource "kubectl_manifest" "argocd-project" {
  count              = var.install_argocd && var.argocd_project != "" && var.argocd_project != null ? 1 : 0
  yaml_body          = file(var.argocd_project)
  override_namespace = var.argocd_namespace
  depends_on         = [kubectl_manifest.argocd, data.http.argocd_file]
}