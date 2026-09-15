resource "azurerm_private_dns_mx_record" "mx_records" {
  for_each = {
    for key, value in try(var.records.mx, {}) : key => value
    if try(value.resource_id, null) == null
  }

  name                = each.value.name
  private_dns_zone_id = var.private_dns_zone_id
  ttl                 = try(each.value.ttl, 300)
  tags                = merge(var.base_tags, try(each.value.tags, {}))

  dynamic "record" {
    for_each = each.value.records

    content {
      preference = record.value.preference
      exchange   = record.value.exchange
    }
  }
}
