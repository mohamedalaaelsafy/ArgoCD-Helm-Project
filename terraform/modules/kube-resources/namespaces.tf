#===============================================================================================
# Create Namespaces
#===============================================================================================
resource "kubernetes_namespace" "namespaces" {
  count    = var.install_namespaces ? length(var.namespaces) : 0
  provider = kubernetes
  metadata {
    name = var.namespaces[count.index]
  }
}

