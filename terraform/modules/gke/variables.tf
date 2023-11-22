variable "project_id" {
  type = string
}


variable "cluster_name" {
  type = string
}

variable "cluster_region" {
  type = string
}

variable "cluster_zones" {
  type = list(string)
}

variable "machine_type" {
  type = string
}

variable "nodes_per_zone" {
  type = number
}

variable "subnet_name" {
  type = string
}

variable "vpc_name" {
  type = string
}


variable "node_locations" {
  type        = string
  description = "node locations in the node pool"
}

variable "master_authorized_networks" {
  type = list(object({ cidr_block = string, display_name = string }))
}

variable "subnet_cidr_sec1" {
  type = string
}

variable "subnet_cidr_sec2" {
  type = string
}

variable "master_node_cidr" {
  type = string
}
