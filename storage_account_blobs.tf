#
# Storage account blobs can be created as a nested object or isolated to allow RBAC to be set before writing the blob
#

resource "time_sleep" "delay" {
  depends_on = [azurerm_role_assignment.for_deferred]
  for_each   = local.storage.storage_account_blobs

  create_duration = try(each.value.dealy.create_duration, "300s")
}

locals {
  storage_account_blobs_storage_account_key = {
    for blob_key, blob in local.storage.storage_account_blobs : blob_key => try(
      blob.storage_account_key,
      blob.storage_account.key,
      one([
        for storage_account_key, storage_account in local.combined_objects_storage_accounts[try(blob.storage_account.lz_key, local.client_config.landingzone_key)] : storage_account_key
        if can(storage_account.containers[blob.storage_container.key])
      ])
    )
  }
}

module "storage_account_blobs" {
  source     = "./modules/storage_account/blob"
  depends_on = [time_sleep.delay]
  for_each   = local.storage.storage_account_blobs

  storage_container_id = can(each.value.storage_container_name) ? format(
    "%s/blobServices/default/containers/%s",
    local.combined_objects_storage_accounts[try(each.value.storage_account.lz_key, local.client_config.landingzone_key)][local.storage_account_blobs_storage_account_key[each.key]].id,
    each.value.storage_container_name
  ) : local.combined_objects_storage_accounts[try(each.value.storage_account.lz_key, local.client_config.landingzone_key)][local.storage_account_blobs_storage_account_key[each.key]].containers[each.value.storage_container.key].id
  settings        = each.value
  var_folder_path = var.var_folder_path
}

output "storage_account_blobs" {
  value = module.storage_account_blobs

}
