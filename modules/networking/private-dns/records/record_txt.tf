resource "azurerm_private_dns_txt_record" "txt_records" {
  for_each = {
    for key, value in try(var.records.txt, {}) : key => value
    if try(value.resource_id, null) == null
  }

  name                = each.value.name
  private_dns_zone_id = var.private_dns_zone_id
  ttl                 = try(each.value.ttl, 300)
  tags                = merge(var.base_tags, try(each.value.tags, {}))

  dynamic "record" {
    for_each = each.value.records

    content {
      value = record.value.value
    }
  }
}
