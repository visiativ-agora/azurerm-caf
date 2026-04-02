resource "azurerm_redis_cache_access_policy_assignment" "role_assignments" {
  for_each = {
    for assignment in local.redis_role_assignments_flat : assignment.name => assignment
  }

  name               = each.value.name
  redis_cache_id     = azurerm_redis_cache.redis.id
  access_policy_name = each.value.role_name
  object_id          = each.value.principal_id
  object_id_alias    = each.value.alias
}
