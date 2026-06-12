
resource "azurerm_private_dns_zone" "private_dns" {
  name                = var.name
  resource_group_name = local.resource_group_name
  tags                = local.tags
}
