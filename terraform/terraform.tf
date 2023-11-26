terraform {
  backend "gcs" {
    bucket = "argocd-helm"
    prefix = "state"
  }

}

provider "google" {
  project = "<PROJECT_ID>"
  region  = "us-central1"
}


terraform {
  required_providers {
    kubectl = {
      source                = "gavinbunney/kubectl"
      version               = ">= 1.7.0"
      configuration_aliases = [kubectl.kctl]
    }
    kubernetes = {
      source                = "hashicorp/kubernetes"
      configuration_aliases = [kubernetes.k8s]
    }
  }
}

