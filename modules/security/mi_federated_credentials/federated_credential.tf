resource "azurerm_federated_identity_credential" "fed_cred" {
  count = local.is_remote ? 0 : 1

  name                      = var.settings.name
  user_assigned_identity_id = local.parent_id_local
  audience                  = try(var.settings.audience, ["api://AzureADTokenExchange"])
  subject                   = var.settings.subject
  issuer                    = local.issuer

  lifecycle {
    precondition {
      condition     = local.parent_id_local != null
      error_message = "Unable to resolve local managed identity id. Provide settings.user_assigned_identity_id or valid managed_identity lz_key/key."
    }
  }
}

# Federated credential - remote subscription (without azurerm provider alias)
resource "azapi_resource" "fed_cred_remote" {
  count = local.is_remote ? 1 : 0

  type      = "Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31"
  name      = var.settings.name
  parent_id = local.parent_id_remote

  body = {
    properties = {
      issuer    = local.issuer
      subject   = var.settings.subject
      audiences = try(var.settings.audience, ["api://AzureADTokenExchange"])
    }
  }

  lifecycle {
    precondition {
      condition     = local.parent_id_remote != null
      error_message = "Unable to resolve remote managed identity id. Provide settings.user_assigned_identity_id or valid remote.managed_identity lz_key/key."
    }
  }
}