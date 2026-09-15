
resource "azurerm_private_dns_a_record" "a_records" {
  for_each = try(var.settings.private_dns_records.a_records, {})

  name                = each.value.name
  private_dns_zone_id = var.private_dns[try(each.value.lz_key, var.client_config.landingzone_key)][each.value.private_dns_key].id
  ttl                 = each.value.ttl
  records             = [local.private_ip_address]
  tags                = merge(local.tags, try(each.value.tags, {}))
}
