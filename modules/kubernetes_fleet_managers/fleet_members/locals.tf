# locals {
#   fleet_member_properties = can(var.settings.group) ? {
#     clusterResourceId = var.aks_cluster.id
#     group             = var.settings.group
#     } : {
#     clusterResourceId = var.aks_cluster.id
#   }
# }