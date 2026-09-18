variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = bool
}
variable "subnet_id" {}
variable "location" {
  description = "(Required) Resource Location"
  default     = null
}
variable "resource_group_name" {
  description = "Resource group object to deploy the Azure resource"
  type        = string
  default     = null
}
variable "resource_group" {
  description = "Resource group object to deploy the Azure resource"
  type        = any
}
variable "private_dns" {
  default = {}
}
variable "diagnostics" {
  default = null
}
variable "diagnostic_profiles" {
  default = null
}
variable "client_config" {
  description = <<DESCRIPTION
    Client configuration object primarily used for specifying the Azure client context in non-interactive environments,
    such as CI/CD pipelines running under a Service Principal.

    If this variable is left as an empty map (the default), the module will attempt to derive the client configuration
    (like client_id, tenant_id, subscription_id, object_id) from the current Azure provider context
    (e.g., credentials from Azure CLI, VS Code Azure login, or environment variables).

    If you provide a map, it should contain the necessary authentication and context details. The structure used
    when the default is derived includes keys like:
    - client_id
    - landingzone_key
    - logged_aad_app_objectId
    - logged_user_objectId
    - object_id
    - subscription_id
    - tenant_id
    DESCRIPTION
  type        = any
}
