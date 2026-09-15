variable "base_tags" {
  default = {}
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "records" {}
variable "target_resources" {
  default = {}
}
variable "private_dns_zone_id" {}
