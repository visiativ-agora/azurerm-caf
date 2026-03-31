module "deployment" {
  source = "../cognitive_deployment"

  for_each = try(var.settings.deployment, {})

  cognitive_account_id = azurerm_cognitive_account.service.id
  settings             = each.value

  depends_on = [azurerm_cognitive_account.service]
}
