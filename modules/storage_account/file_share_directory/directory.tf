resource "azurerm_storage_share_directory" "share_directory" {
  name              = var.settings.name
  storage_share_url = var.storage_share_url
  metadata          = try(var.settings.metadata, null)
}
