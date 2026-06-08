output "id" {
  description = "Federated Identity Credential ID"
  value       = try(azurerm_federated_identity_credential.fed_cred[0].id, azapi_resource.fed_cred_remote[0].id, null)
}