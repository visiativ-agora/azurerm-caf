locals {
  # Service Endpoint Policy IDs resolution
  # Supports both direct IDs and remote_objects references
  service_endpoint_policy_ids = var.service_endpoint_policy_ids != null ? var.service_endpoint_policy_ids : (
    try(var.settings.service_endpoint_policies, null) != null ? flatten([
      for policy_key in try(var.settings.service_endpoint_policies, []) : [
        coalesce(
          try(var.settings.service_endpoint_policy_ids[policy_key], null),
          try(var.remote_objects.subnet_service_endpoint_storage_policies[try(var.settings.service_endpoint_policy_lz_key, var.client_config.landingzone_key)][policy_key].id, null)
        )
      ]
    ]) : null
  )

  # azurerm 5.x migration: support both legacy service_endpoints (list of strings)
  # and new service_endpoint objects with optional network_identifier.
  service_endpoint_input = try(var.settings.service_endpoint, null) != null ? try(var.settings.service_endpoint, null) : try(var.settings.service_endpoints, null)

  service_endpoint_blocks = local.service_endpoint_input == null ? [
    for service in sort(try(var.service_endpoints, [])) : {
      service            = service
      network_identifier = null
    }
  ] : can(local.service_endpoint_input.service) ? [
    {
      service            = local.service_endpoint_input.service
      network_identifier = try(local.service_endpoint_input.network_identifier, null)
    }
  ] : can(local.service_endpoint_input[0].service) ? [
    for endpoint in local.service_endpoint_input : {
      service            = try(endpoint.service, endpoint)
      network_identifier = try(endpoint.network_identifier, null)
    }
  ] : [
    for service in sort(local.service_endpoint_input) : {
      service            = service
      network_identifier = null
    }
  ]
}
