resource "azurerm_search_shared_private_link_service" "search_service_shared_private_link_service" {
  name               = var.settings.name
  search_service_id  = var.search_service_id
  subresource_name   = var.settings.subresource_name
  target_resource_id = var.target_resource_id
  request_message    = try(var.settings.request_message, null)
}

resource "time_sleep" "wait_for_private_endpoint" {
  create_duration = "2m"
  depends_on      = [azurerm_search_shared_private_link_service.search_service_shared_private_link_service]

  triggers = {
    timestamp = timestamp()
  }
}

data "azapi_resource" "target_resource" {
  type                   = "${var.target_resource_type}@${var.target_resource_api_version}"
  resource_id            = var.target_resource_id
  response_export_values = ["properties.privateEndpointConnections"]

  depends_on = [time_sleep.wait_for_private_endpoint]
}

locals {
  connections = try(data.azapi_resource.target_resource.output.properties.privateEndpointConnections, [])

  pending_connection = try(
    [for conn in local.connections : conn if conn.properties.privateLinkServiceConnectionState.status == "Pending"][0],
    null
  )
}

resource "azapi_update_resource" "approve_connection" {
  count = var.settings.auto_approve ? 1 : 0

  type        = "${var.target_resource_type}/privateEndpointConnections@${var.target_resource_api_version}"
  resource_id = try(local.pending_connection.id, null)

  body = {
    properties = {
      privateLinkServiceConnectionState = {
        status      = "Approved"
        description = "Approved by Terraform"
      }
    }
  }

  lifecycle {
    ignore_changes = all
  }
}
