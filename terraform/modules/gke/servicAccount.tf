module "acr-sa" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "~> 3.0"
  project_id = var.project_id
  names      = ["argocd-cluster-sa"]
  project_roles = [
    "${var.project_id}=>roles/artifactregistry.reader"
  ]
}