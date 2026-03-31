
module "kubernetes_fleet_managers" {
  source   = "./modules/kubernetes_fleet_managers/fleet_manager"
  for_each = local.kubernetes_fleet_managers.fleet_managers

  client_config       = local.client_config
  global_settings     = local.global_settings
  diagnostic_profiles = try(each.value.diagnostic_profiles, {})
  diagnostics         = local.combined_diagnostics
  settings            = each.value
  location            = can(local.global_settings.regions[each.value.region]) ? local.global_settings.regions[each.value.region] : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].location
  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)].name
  base_tags           = try(local.global_settings.inherit_tags, false) ? try(local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].tags, {}) : {}
  tags                = try(each.value.tags, {})
}

output "kubernetes_fleet_managers" {
  value = module.kubernetes_fleet_managers
}

locals {
  all_fleet_members = flatten([
    for fm_key, fm_config in try(local.kubernetes_fleet_managers.fleet_managers, {}) : [
      for member_key, member_config in try(fm_config.members, {}) : {
        unique_key        = "${fm_key}-${member_key}"
        lz_key            = try(member_config.lz_key, local.client_config.landingzone_key)
        key               = try(member_config.key, member_key)
        group             = try(member_config.group, null)
        name              = try(member_config.name, null)
        fleet_manager_key = fm_key
        member_config     = member_config
      }
    ]
  ])

  fleet_members_for_each = {
    for member in local.all_fleet_members : member.unique_key => member
  }
}

module "kubernetes_fleet_members" {
  depends_on = [module.kubernetes_fleet_managers]
  source     = "./modules/kubernetes_fleet_managers/fleet_members"
  for_each   = local.fleet_members_for_each

  global_settings = var.global_settings
  client_config   = var.client_config
  settings        = each.value.member_config
  name            = local.combined_objects_aks_clusters[try(each.value.lz_key, var.client_config.landingzone_key)][try(each.value.key)].cluster_name
  aks_cluster     = local.combined_objects_aks_clusters[try(each.value.lz_key, var.client_config.landingzone_key)][try(each.value.key)]
  fleet_manager   = module.kubernetes_fleet_managers[each.value.fleet_manager_key]
}
