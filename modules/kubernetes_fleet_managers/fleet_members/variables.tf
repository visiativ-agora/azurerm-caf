variable "global_settings" {
  description = "Global settings object (see module README.md)."
}

variable "client_config" {
  description = "Client configuration object (see module README.md)."
}

variable "settings" {
  description = "Specific settings for the module configuration."
}

variable "aks_cluster" {
  description = "Azure Kubernetes Service (AKS) cluster object."
}

variable "fleet_manager" {
  description = "(Required) Fleet manager object for managing Kubernetes clusters."
}

variable "name" {
  description = "(Required) Specifies the name of this Kubernetes Fleet Member."
}