# secret.tf
# Placeholder for azurerm_cdn_frontdoor_secret resource implementation

data "azurerm_key_vault_certificate" "manual_certs" {
  for_each = {
    for key, secret in try(var.settings.secrets, {}) :
    key => secret.secret.customer_certificate.keyvault_certificate
    if try(secret.secret.customer_certificate.keyvault_certificate.certificate_name, null) != null
  }

  name = each.value.certificate_name

  key_vault_id = (
    can(each.value.keyvault_id) && each.value.keyvault_id != ""
    ? each.value.keyvault_id
    : try(
      var.remote_objects.keyvault_certificates[
        try(each.value.lz_key, var.client_config.landingzone_key)
      ][each.value.key].id,
      null
    )
  )
}


# resource "azurerm_cdn_frontdoor_secret" "secret" {
#   name = azurecaf_name.secret.result
#   cdn_frontdoor_profile_id = coalesce(
#     try(var.settings.cdn_frontdoor_profile_id, null),
#     try(var.remote_objects.cdn_frontdoor_profile.id, null),
#     try(var.remote_objects.cdn_frontdoor_profiles[try(var.settings.cdn_frontdoor_profile.lz_key, var.client_config.landingzone_key)][var.settings.cdn_frontdoor_profile.key].id, null)
#   )
#   secret {
#     customer_certificate {
#       key_vault_certificate_id = coalesce(
#         try(var.settings.secret.customer_certificate.key_vault_certificate_id, null),
#         try(var.remote_objects.keyvault_certificate_requests[try(var.settings.secret.customer_certificate.certificate_request.lz_key, var.client_config.landingzone_key)][var.settings.secret.customer_certificate.certificate_request.key].secret_id, null),
#         try(var.remote_objects.keyvault_certificates[try(var.settings.secret.customer_certificate.keyvault_certificate.lz_key, var.client_config.landingzone_key)][var.settings.secret.customer_certificate.keyvault_certificate.key].secret_id, null),
#         try(data.azurerm_key_vault_certificate.manual_certs, null)
#       )
#     }
#   }
#   dynamic "timeouts" {
#     for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]
#     content {
#       create = try(timeouts.value.create, null)
#       read   = try(timeouts.value.read, null)
#       delete = try(timeouts.value.delete, null)
#     }
#   }
# }


resource "azurerm_cdn_frontdoor_secret" "secret" {
  for_each = try(var.settings.secrets, {})

  name = each.value.name
  cdn_frontdoor_profile_id = coalesce(
    try(var.settings.cdn_frontdoor_profile_id, null),
    try(var.remote_objects.cdn_frontdoor_profile.id, null),
    try(var.remote_objects.cdn_frontdoor_profiles[try(var.settings.cdn_frontdoor_profile.lz_key, var.client_config.landingzone_key)][var.settings.cdn_frontdoor_profile.key].id, null)
  )

  secret {
    customer_certificate {
      key_vault_certificate_id = coalesce(
        try(each.value.secret.customer_certificate.key_vault_certificate_id, null),
        try(var.remote_objects.keyvault_certificate_requests[try(each.value.secret.customer_certificate.certificate_request.lz_key, var.client_config.landingzone_key)][each.value.secret.customer_certificate.certificate_request.key].secret_id, null),
        try(var.remote_objects.keyvault_certificates[try(each.value.secret.customer_certificate.keyvault_certificate.lz_key, var.client_config.landingzone_key)][each.value.secret.customer_certificate.keyvault_certificate.key].secret_id, null),
        try(data.azurerm_key_vault_certificate.manual_certs[each.key].secret_id, null)
      )
    }
  }

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
