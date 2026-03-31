module "search_service" {
  source   = "./modules/search_service"
  for_each = local.search_services.search_services

  client_config       = local.client_config
  global_settings     = local.global_settings
  resource_group      = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)]
  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : null
  location            = lookup(each.value, "region", null) == null ? local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].location : local.global_settings.regions[each.value.region]
  settings            = each.value
  base_tags           = local.global_settings.inherit_tags
  identity            = try(each.value.identity, null)
  private_endpoints   = try(each.value.private_endpoints, {})
  private_dns         = local.combined_objects_private_dns
  vnets               = local.combined_objects_networking
  virtual_subnets     = local.combined_objects_virtual_subnets
}

output "search_service" {
  value = module.search_service
}


locals {
  shared_private_access = flatten([
    for search_key, search_val in local.search_services.search_services : try([
      for spa_key, spa_val in search_val.shared_private_access : {
        search_key = search_key
        spa_key    = spa_key
        settings   = spa_val
      }
    ], [])
  ])

  target_resource_type_map = {
    "storage"         = "Microsoft.Storage/storageAccounts"
    "cosmosdbaccount" = "Microsoft.DocumentDB/databaseAccounts"
  }

  target_resource_api_version_map = {
    "storage"         = "2024-01-01"
    "cosmosdbaccount" = "2025-05-01-preview"
  }
}

module "search_shared_private_link_service" {
  depends_on = [module.search_service]
  source     = "./modules/search_service/private_link"
  for_each   = { for idx, val in local.shared_private_access : "${val.search_key}-${val.spa_key}" => val }

  client_config     = local.client_config
  global_settings   = local.global_settings
  settings          = each.value.settings
  search_service_id = module.search_service[each.value.search_key].id
  target_resource_id = lookup({
    "storage" = try(local.combined_objects_storage_accounts[
      try(each.value.settings.target_resource.lz_key, local.client_config.landingzone_key)
    ][each.value.settings.target_resource.key].id, null)
    "cosmosdbaccount" = try(local.combined_objects_cosmos_dbs[
      try(each.value.settings.target_resource.lz_key, local.client_config.landingzone_key)
    ][each.value.settings.target_resource.key].id, null)
  }, each.value.settings.target_resource.type, null)


  target_resource_type = lookup(
    local.target_resource_type_map,
    each.value.settings.target_resource.type,
    null
  )
  target_resource_api_version = lookup(
    local.target_resource_api_version_map,
    each.value.settings.target_resource.type,
    null
  )
}


output "search_shared_private_link_service" {
  value = module.search_shared_private_link_service
}