module "signalr_services" {
  source   = "./modules/messaging/signalr_service"
  for_each = local.messaging.signalr_services

  global_settings     = local.global_settings
  client_config       = local.client_config
  settings            = each.value
  private_endpoints   = try(each.value.private_endpoints, {})
  vnets               = local.combined_objects_networking
  private_dns         = local.combined_objects_private_dns
  resource_groups     = local.combined_objects_resource_groups
  base_tags           = local.global_settings.inherit_tags
  resource_group      = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)]
  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : null
  location            = lookup(each.value, "region", null) == null ? local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].location : local.global_settings.regions[each.value.region]
  managed_identities  = local.combined_objects_managed_identities

  remote_objects = {
    resource_groups = local.combined_objects_resource_groups
    vnets           = local.combined_objects_networking
  }
}

output "signalr_services" {
  value = module.signalr_services
}
