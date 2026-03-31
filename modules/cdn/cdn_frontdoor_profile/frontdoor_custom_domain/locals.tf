locals {
  zone_name = try(var.settings.dns_zone.lz_key, null) == null ? var.remote_objects.dns_zones[var.client_config.landingzone_key][var.settings.dns_zone.key].name : var.remote_objects.dns_zones[var.settings.dns_zone.lz_key][var.settings.dns_zone.key].name
  subdomain_for_txt = trim(
    replace(var.settings.host_name, ".${local.zone_name}", ""), "."
  )
}