locals {
  parent_id = coalesce(
    try(var.settings.managed_identity.id, null),
    try(var.managed_identities[
      try(var.settings.managed_identity.lz_key, var.client_config.landingzone_key)
    ][var.settings.managed_identity.key].id, null)
  )

  resource_group_name = coalesce(
    try(var.resource_group_name, null),
    split("/", local.parent_id)[4]
  )
}