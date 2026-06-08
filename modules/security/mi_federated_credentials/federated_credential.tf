resource "azurerm_federated_identity_credential" "fed_cred" {
  count = try(var.settings.remote, false) ? 0 : 1

  name                = var.settings.name
  resource_group_name = local.resource_group_name
  parent_id           = local.parent_id
  audience            = try(var.settings.audience, ["api://AzureADTokenExchange"])
  subject             = var.settings.subject
  issuer              = coalesce(try(var.oidc_issuer_url, null), try(var.settings.oidc_issuer_url, null))
}

# Federated credential - remote subscription
resource "azurerm_federated_identity_credential" "fed_cred_remote" {
  count = try(var.settings.remote, false) ? 1 : 0

  provider = azurerm.gitops

  name                = var.settings.name
  resource_group_name = local.resource_group_name
  parent_id           = local.parent_id
  audience            = try(var.settings.audience, ["api://AzureADTokenExchange"])
  subject             = var.settings.subject
  issuer              = coalesce(try(var.oidc_issuer_url, null), try(var.settings.oidc_issuer_url, null))
}