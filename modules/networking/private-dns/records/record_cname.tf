resource "azurerm_private_dns_cname_record" "cname_records" {
  for_each = {
    for key, value in try(var.records.cname, {}) : key => value
    if try(value.resource_id, null) == null
  }

  name                = each.value.name
  private_dns_zone_id = var.private_dns_zone_id
  ttl                 = try(each.value.ttl, 300)
  record              = try(each.value.record, null)
  tags                = merge(var.base_tags, try(each.value.tags, {}))
}
