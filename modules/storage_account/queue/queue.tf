resource "azurerm_storage_queue" "queue" {
  name                 = var.settings.name
  storage_account_id   = var.storage_account_id
  metadata             = try(var.settings.metadata, null)
}