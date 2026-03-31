# output "secret_id" {
#   value = azurerm_cdn_frontdoor_secret.secret.id
# }

output "secret_ids" {
  value = { for k, v in azurerm_cdn_frontdoor_secret.secret : k => v.id }
}