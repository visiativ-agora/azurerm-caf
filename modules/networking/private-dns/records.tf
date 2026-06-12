module "records" {
  source     = "./records"
  count      = try(var.settings.records, null) == null ? 0 : 1
  depends_on = [azurerm_private_dns_zone.private_dns]

  base_tags           = local.tags
  client_config       = var.client_config
  resource_group_name = var.resource_group_name
  records             = var.settings.records
  zone_name           = azurerm_private_dns_zone.private_dns.name
}