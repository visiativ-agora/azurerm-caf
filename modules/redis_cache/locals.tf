locals {
	tags = var.base_tags ? merge(
    var.global_settings.tags,
    try(var.resource_group.tags, null),
    try(var.redis.tags, null)
  ) : try(var.redis.tags, null)

  location            = coalesce(var.location, var.resource_group.location)
  resource_group_name = coalesce(var.resource_group_name, var.resource_group.name)

  redis_url = "rediss://:${azurerm_redis_cache.redis.primary_access_key}@${azurerm_redis_cache.redis.hostname}:${azurerm_redis_cache.redis.ssl_port}"

  redis_role_assignments_flat = flatten([
    for role_name, role_data in try(var.redis_role_assignment, {}) : [
      for key in role_data.managed_identities.keys : {
        name         = "${role_name}-${key}-assignment"
        role_name    = role_name
        principal_id = var.managed_identities[try(role_data.managed_identities.lz_key, var.client_config.landingzone_key)][key].principal_id
        alias        = var.managed_identities[try(role_data.managed_identities.lz_key, var.client_config.landingzone_key)][key].name
      }
    ]
  ])
}
