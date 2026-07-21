module "deployment" {
  source = "../cognitive_account_project"

  for_each = try(var.settings.deployment, {})

  cognitive_account_id = azurerm_cognitive_account.service.id
  location             = local.location
  settings             = each.value
  tags                 = local.tags

  depends_on = [azurerm_cognitive_account.service]
}
