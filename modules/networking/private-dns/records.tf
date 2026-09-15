module "records" {
  source     = "./records"
  count      = try(var.settings.records, null) == null ? 0 : 1
  depends_on = [azurerm_private_dns_zone.private_dns]

  base_tags           = local.tags
  client_config       = var.client_config
  records             = var.settings.records
  private_dns_zone_id = azurerm_private_dns_zone.private_dns.id
}
