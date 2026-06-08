variable "settings" {
  description = "Federated credential settings. Supports managed_identity.{lz_key,key}|managed_identity.id|user_assigned_identity_id and remote=true or remote.managed_identity.{lz_key,key,id}."
  default = {}
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
}
variable "resource_group" {
  default = {}
}
variable "managed_identities" {
  default = {}
}
variable "oidc_issuer_url" {
  default = null
}
variable "resource_group_name" {
}