resource "azurerm_private_dns_cname_record" "cname_records" {
  for_each = {
    for key, value in try(var.records.cname, {}) : key => value
    if try(value.resource_id, null) == null
  }

  name                = each.value.name
  zone_name           = var.zone_name
  resource_group_name = var.resource_group_name
  ttl                 = try(each.value.ttl, 300)
  record              = try(each.value.record, null)
  tags                = merge(var.base_tags, try(each.value.tags, {}))
}
