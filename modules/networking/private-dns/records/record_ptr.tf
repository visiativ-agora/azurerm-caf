resource "azurerm_private_dns_ptr_record" "ptr_records" {
  for_each = {
    for key, value in try(var.records.ptr, {}) : key => value
    if try(value.resource_id, null) == null
  }

  name                = each.value.name
  zone_name           = var.zone_name
  resource_group_name = var.resource_group_name
  ttl                 = try(each.value.ttl, 300)
  records             = each.value.records
  tags                = merge(var.base_tags, try(each.value.tags, {}))
}
