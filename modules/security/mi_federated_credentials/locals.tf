locals {
  is_remote = try(tobool(var.settings.remote), false) || try(var.settings.remote.managed_identity != null, false)

  parent_id_local = coalesce(
    try(var.settings.user_assigned_identity_id, null),
    try(var.settings.managed_identity.id, null),
    try(var.managed_identities[
      try(var.settings.managed_identity.lz_key, var.client_config.landingzone_key)
    ][var.settings.managed_identity.key].id, null)
  )

  parent_id_remote = coalesce(
    try(var.settings.user_assigned_identity_id, null),
    try(var.settings.remote.managed_identity.id, null),
    try(var.settings.managed_identity.id, null),
    try(var.managed_identities[
      try(var.settings.remote.managed_identity.lz_key, try(var.settings.managed_identity.lz_key, var.client_config.landingzone_key))
    ][coalesce(try(var.settings.remote.managed_identity.key, null), try(var.settings.managed_identity.key, null))].id, null)
  )

  parent_id = local.is_remote ? local.parent_id_remote : local.parent_id_local

  issuer = coalesce(
    try(var.oidc_issuer_url, null),
    try(var.settings.oidc_issuer_url, null)
  )

  resource_group_name = coalesce(
    try(var.resource_group_name, null),
    split("/", local.parent_id)[4]
  )
}