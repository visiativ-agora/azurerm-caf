module "file_share_directory" {
  source            = "../file_share_directory"
  for_each          = try(var.settings.directories, {})
  storage_share_url = azurerm_storage_share.fs.url
  settings          = each.value
}
