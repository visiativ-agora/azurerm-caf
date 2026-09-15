variable "share_id" {
  default = null
}

variable "storage_share_url" {
  default = null
}
variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
