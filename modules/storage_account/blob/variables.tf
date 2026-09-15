variable "storage_container_id" {
  description = "Specifies the ID of the Storage Container."
  type        = string
}
variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "var_folder_path" {
  description = "The path to the folder containing the variables file."
  type        = string
}
