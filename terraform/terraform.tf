terraform {
  backend "gcs" {
    bucket = "argocd-helm"
    # prefix = "infrastructure"
  }
}

provider "google" {
  project = "vodafone-technical-task"
  region  = "us-central1"
}


# terraform {
#   required_providers {
#     kubectl = {
#       source  = "gavinbunney/kubectl"
#       version = ">= 1.7.0"
#     }
#   }
# }


