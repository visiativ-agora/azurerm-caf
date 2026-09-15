resource "azurerm_private_dns_ptr_record" "ptr_records" {
  for_each = {
    for key, value in try(var.records.ptr, {}) : key => value
    if try(value.resource_id, null) == null
  }

  name                = each.value.name
  private_dns_zone_id = var.private_dns_zone_id
  ttl                 = try(each.value.ttl, 300)
  records             = each.value.records
  tags                = merge(var.base_tags, try(each.value.tags, {}))
}
