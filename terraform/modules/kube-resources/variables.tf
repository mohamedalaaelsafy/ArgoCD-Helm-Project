### NAMESPACES ####
variable "install_namespaces" {
  type = bool
}
variable "namespaces" {
  type = list(string)
}


### ARGOCD ###
variable "install_argocd" {
  type = bool
}
variable "argocd_namespace" {
  type = string
}

variable "argocd_project" {
  type = string
  default = ""
}
variable "argocd_app" {
  type = string
  default = ""
}
variable "argocd_cm" {
  type = string
  default = ""
}
variable "argocd_secret" {
  type = string
  default = ""
}

