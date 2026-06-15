resource "azurerm_private_dns_txt_record" "txt_records" {
  for_each = {
    for key, value in try(var.records.txt, {}) : key => value
    if try(value.resource_id, null) == null
  }

  name                = each.value.name
  zone_name           = var.zone_name
  resource_group_name = var.resource_group_name
  ttl                 = try(each.value.ttl, 300)
  tags                = merge(var.base_tags, try(each.value.tags, {}))

  dynamic "record" {
    for_each = each.value.records

    content {
      value = record.value.value
    }
  }
}
