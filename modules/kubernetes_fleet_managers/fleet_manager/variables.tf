variable "location" {
  description = "(Required) The Azure Region where the Kubernetes Fleet Manager should exist. Changing this forces a new Kubernetes Fleet Manager to be created."
  type        = string
}
variable "diagnostics" {}
variable "diagnostic_profiles" {
  default = {}
}
variable "resource_group_name" {
  description = "(Required) Specifies the name of the Resource Group within which this Kubernetes Fleet Manager should exist. Changing this forces a new Kubernetes Fleet Manager to be created."
  type        = string
}
variable "tags" {
  description = "(Optional) A mapping of tags which should be assigned to the Kubernetes Fleet Manager."
  default     = null
}
variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
}
variable "global_settings" {
  description = "Global settings object (see module README.md)"
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
}
variable "settings" {}
