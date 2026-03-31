# locals {
#   server_name = "${var.server_name}${var.cloud.sqlServerHostname}"

#   db_permissions = {
#     for group_key, group in try(var.settings.db_permissions, {}) : group_key => {
#       db_roles = group.db_roles

#       db_usernames = distinct(compact(flatten(concat(
#         [
#           for mi_key, mi_value in try(group, {}) : [
#             for k in try(mi_value.keys, []) :
#             try(
#               var.managed_identities[mi_value.lz_key][k].name,
#               var.managed_identities[var.client_config.landingzone_key][k].name,
#               null
#             )
#           ] if mi_key == "managed_identities"
#         ],
#         [
#           for aad_key, aad_value in try(group, {}) : [
#             for k in try(aad_value.keys, []) :
#             try(
#               var.azuread_groups[aad_value.lz_key][k].display_name,
#               var.azuread_groups[var.client_config.landingzone_key][k].display_name,
#               null
#             )
#           ] if aad_key == "azuread_groups"
#         ]
#       ))))
#     }
#   }
# }

locals {
  server_name = "${var.server_name}${var.cloud.sqlServerHostname}"

  db_permissions = {
    for group_key, group in try(var.settings.db_permissions, {}) : group_key => {
      db_roles = group.db_roles

      db_usernames = distinct(compact(flatten(concat(
        [
          # managed_identities
          for mi_key, mi_value in try(group, {}) : [
            for k in try(
              mi_value.keys,
              mi_value.managed_identity_keys,
              []
            ) :
            try(
              var.managed_identities[try(mi_value.lz_key, var.client_config.landingzone_key)][k].name,
              null
            )
          ] if mi_key == "managed_identities"
        ],
        [
          # azuread_groups
          for aad_key, aad_value in try(group, {}) : [
            for k in try(aad_value.keys, []) :
            try(
              var.azuread_groups[try(aad_value.lz_key, var.client_config.landingzone_key)][k].display_name,
              null
            )
          ] if aad_key == "azuread_groups"
        ]
      ))))
    }
  }
}
