resource "azurerm_cdn_frontdoor_custom_domain" "custom_domain" {
  name = azurecaf_name.custom_domain.result
  cdn_frontdoor_profile_id = coalesce(
    try(var.settings.cdn_frontdoor_profile_id, null),
    try(var.remote_objects.cdn_frontdoor_profile.id, null),
    try(var.remote_objects.cdn_frontdoor_profiles[try(var.settings.cdn_frontdoor_profile.lz_key, var.client_config.landingzone_key)][var.settings.cdn_frontdoor_profile.key].id, null)
  )
  host_name   = var.settings.host_name
  dns_zone_id = try(var.settings.dns_zone.lz_key, null) == null ? var.remote_objects.dns_zones[var.client_config.landingzone_key][var.settings.dns_zone.key].id : var.remote_objects.dns_zones[var.settings.dns_zone.lz_key][var.settings.dns_zone.key].id

  # Pre-validated custom domain (for Azure services like Static Web App)
  # pre_validated_cdn_frontdoor_custom_domain_id = try(var.settings.pre_validated_cdn_frontdoor_custom_domain_id, null)

  tls {
    certificate_type    = try(var.settings.tls.certificate_type, null)
    minimum_tls_version = try(var.settings.tls.min_tls_version, null)
    cdn_frontdoor_secret_id = try(
      try(var.settings.tls.cdn_frontdoor_secret_id, null),
      try(var.remote_objects.cdn_frontdoor_secrets[try(var.settings.tls.cdn_frontdoor_secret.lz_key, var.client_config.landingzone_key)][var.settings.tls.cdn_frontdoor_secret.key].id, null),
      try(var.remote_objects.cdn_frontdoor_secrets[var.settings.tls.secret_key].id, null),
      null
    )
  }

  # timeouts block (static, not dynamic)
  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]
    content {
      create = try(timeouts.value.create, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
      read   = try(timeouts.value.read, null)
    }
  }
}
resource "azurerm_dns_txt_record" "b2c" {
  count = can(var.settings.dns_zone.key) ? 1 : 0

  name                = "_dnsauth.${local.subdomain_for_txt}"
  zone_name           = local.zone_name
  resource_group_name = try(var.settings.dns_zone.lz_key, null) == null ? var.remote_objects.dns_zones[var.client_config.landingzone_key][var.settings.dns_zone.key].resource_group_name : var.remote_objects.dns_zones[var.settings.dns_zone.lz_key][var.settings.dns_zone.key].resource_group_name
  ttl                 = 60

  record {
    value = azurerm_cdn_frontdoor_custom_domain.custom_domain.validation_token
  }
}
