resource "azapi_resource" "kfme" {
  type = "Microsoft.ContainerService/fleets/members@2024-04-01"
  name = try(
    lower(var.aks_cluster.cluster_name),
    lower(var.aks_cluster.name),
    var.settings.name
  )
  parent_id = var.fleet_manager.id

  # body = jsonencode({
  #   properties = local.fleet_member_properties
  # })
  body = {
    properties = merge(
      {
        clusterResourceId = var.aks_cluster.id
      },
      can(var.settings.group) ? { group = var.settings.group } : {},
      can(var.settings.labels) ? { labels = var.settings.labels } : {}
    )
  }

  schema_validation_enabled = false
  response_export_values    = ["properties.outputs"]
}
