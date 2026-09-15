locals {
  # Keep backward compatibility with pre-5.x flat NIC fields by normalizing
  # both legacy and new-style input into the provider 5.x ip_configuration block.
  replication_target_subnet_name = can(var.settings.replication.target.network.subnet_name) ? var.settings.replication.target.network.subnet_name : var.vnets[try(var.settings.replication.target.network.lz_key, var.client_config.landingzone_key)][var.settings.replication.target.network.vnet_key].subnets[var.settings.replication.target.network.subnet_key].name

  replication_test_subnet_name = can(var.settings.replication.target.test_network.subnet_name) ? var.settings.replication.target.test_network.subnet_name : var.vnets[try(var.settings.replication.target.test_network.lz_key, var.client_config.landingzone_key)][var.settings.replication.target.test_network.vnet_key].subnets[var.settings.replication.target.test_network.subnet_key].name

  normalized_network_interfaces = {
    for nic_key, nic in var.virtual_machine_nics : nic_key => {
      source_network_interface_id = nic.id
      ip_configurations = length(try(nic.ip_configuration, [])) > 0 ? nic.ip_configuration : [
        {
          name = coalesce(
            try(var.settings.replication.target.network_interface.ip_configuration_name, null),
            try(values(nic.ip_configurations)[0].name, null),
            try(values(nic.ip_configuration)[0].name, null),
            format("ipconfig-%s", tostring(nic_key))
          )
          target_subnet_name                              = local.replication_target_subnet_name
          failover_test_subnet_name                       = local.replication_test_subnet_name
          target_static_ip                                = try(var.settings.replication.target.network_interface.target_static_ip, null)
          failover_test_static_ip                         = try(var.settings.replication.target.network_interface.failover_test_static_ip, null)
          recovery_public_ip_address_id                   = try(var.settings.replication.target.network_interface.recovery_public_ip_address_id, null)
          failover_test_public_ip_address_id              = try(var.settings.replication.target.network_interface.failover_test_public_ip_address_id, null)
          recovery_load_balancer_backend_address_pool_ids = try(var.settings.replication.target.network_interface.recovery_load_balancer_backend_address_pool_ids, null)
        }
      ]
    }
  }
}

resource "azurerm_site_recovery_replicated_vm" "replication" {
  count = try(var.settings.replication, null) == null ? 0 : 1

  name = "${var.virtual_machine_name}-repl"
  resource_group_name = coalesce(
    try(var.settings.replication.recovery_vault_rg, null),
    try(split("/", var.settings.replication.recovery_vault_id)[4], null),
    try(var.recovery_vaults[var.client_config.landingzone_key][var.settings.replication.vault_key].resource_group_name, null),
    try(var.recovery_vaults[var.settings.replication.lz_key][var.settings.replication.vault_key].resource_group_name, null)
  )

  recovery_vault_name = coalesce(
    try(var.settings.replication.recovery_vault_name, null),
    try(split("/", var.settings.replication.recovery_vault_id)[8], null),
    try(var.recovery_vaults[var.client_config.landingzone_key][var.settings.replication.vault_key].name, null),
    try(var.recovery_vaults[var.settings.replication.lz_key][var.settings.replication.vault_key].name, null)
  )
  recovery_replication_policy_id = coalesce(
    try(var.settings.replication.replication_policy_id, null),
    try(var.recovery_vaults[var.client_config.landingzone_key][var.settings.replication.vault_key].replication_policies[var.settings.replication.policy_key].id, null),
    try(var.recovery_vaults[var.settings.replication.lz_key][var.settings.replication.vault_key].replication_policies[var.settings.replication.policy_key].id, null)
  )

  source_recovery_fabric_name = coalesce(
    try(var.settings.replication.source.recovery_fabric_name, null),
    try(var.recovery_vaults[var.client_config.landingzone_key][var.settings.replication.vault_key].recovery_fabrics[var.settings.replication.source.recovery_fabric_key].name, null),
    try(var.recovery_vaults[var.settings.replication.lz_key][var.settings.replication.vault_key].recovery_fabrics[var.settings.replication.source.recovery_fabric_key].name, null)
  )
  source_vm_id = replace(replace(replace(lower(var.virtual_machine_id), "microsoft.compute", "Microsoft.Compute"), "resourcegroups", "resourceGroups"), "virtualmachines", "virtualMachines")

  source_recovery_protection_container_name = coalesce(
    try(var.settings.replication.source.protection_container_name, null),
    try(var.recovery_vaults[var.client_config.landingzone_key][var.settings.replication.vault_key].protection_containers[var.settings.replication.source.protection_container_key].name, null),
    try(var.recovery_vaults[var.settings.replication.lz_key][var.settings.replication.vault_key].protection_containers[var.settings.replication.source.protection_container_key].name, null)
  )

  target_resource_group_id = coalesce(
    try(var.resource_groups[var.client_config.landingzone_key][var.settings.replication.target.resource_group_key].id, null),
    try(var.recovery_vaults[var.settings.replication.target.resource_group.lz_key][var.settings.replication.resource_group.key].id, null)
  )
  target_recovery_fabric_id = coalesce(
    try(var.settings.replication.target.recovery_fabric_id, null),
    try(var.recovery_vaults[var.client_config.landingzone_key][var.settings.replication.vault_key].recovery_fabrics[var.settings.replication.target.recovery_fabric_key].id, null),
    try(var.recovery_vaults[var.settings.replication.lz_key][var.settings.replication.vault_key].recovery_fabrics[var.settings.replication.target.recovery_fabric_key].id, null)
  )
  target_recovery_protection_container_id = coalesce(
    try(var.settings.replication.source.protection_container_id, null),
    try(var.recovery_vaults[var.client_config.landingzone_key][var.settings.replication.vault_key].protection_containers[var.settings.replication.target.protection_container_key].id, null),
    try(var.recovery_vaults[var.settings.replication.lz_key][var.settings.replication.vault_key].protection_containers[var.settings.replication.target.protection_container_key].id, null)
  )
  target_zone = try(var.settings.replication.target.zone, "")
  target_network_id = coalesce(
    try(var.settings.replication.target.network.vnet_id, null),
    try(var.vnets[try(var.settings.replication.target.network.lz_key, var.client_config.landingzone_key)][var.settings.replication.target.network.vnet_key].id, null)
  )

  test_network_id = coalesce(
    try(var.settings.replication.target.test_network.vnet_id, null),
    try(var.vnets[try(var.settings.replication.target.test_network.lz_key, var.client_config.landingzone_key)][var.settings.replication.target.test_network.vnet_key].id, null)
  )

  managed_disk {
    disk_id = format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Compute/disks/%s", var.client_config.subscription_id, lower(var.virtual_machine_os_disk.resource_group_name), lower(var.virtual_machine_os_disk.name))

    staging_storage_account_id = coalesce(
      try(var.storage_accounts[var.client_config.landingzone_key][var.settings.replication.staging_storage_account_key].id, null),
      try(var.storage_accounts[var.settings.replication.staging_storage_account.lz_key][var.settings.replication.staging_storage_account.key].id, null)
    )
    target_resource_group_id = coalesce(
      try(var.resource_groups[var.client_config.landingzone_key][var.settings.replication.target.resource_group_key].id, null),
      try(var.recovery_vaults[var.settings.replication.target.resource_group.lz_key][var.settings.replication.resource_group.key].id, null)
    )
    target_disk_type         = try(var.settings.replication.target.os_disk_storage_type, var.virtual_machine_os_disk.storage_account_type) # When I retrieve the storage account type, the plan detects a change and rebuilds the replication item. If anyone has an idea how to solve this problem
    target_replica_disk_type = try(var.settings.replication.target.os_disk_replica_storage_type, var.settings.replication.target.os_disk_storage_type, var.virtual_machine_os_disk.storage_account_type)
    # target_disk_encryption_set_id = try(var.settings.os_disk.disk_encryption_set_key, null) == null ? null : var.disk_encryption_sets[try(var.settings.os_disk.lz_key, var.client_config.landingzone_key)][var.settings.os_disk.disk_encryption_set_key].id

    target_disk_encryption_set_id = contains(
      keys(var.disk_encryption_sets[try(var.settings.os_disk.lz_key, var.client_config.landingzone_key)]),
      var.settings.virtual_machine_settings.windows.os_disk.disk_encryption_set_key
    ) ? var.disk_encryption_sets[try(var.settings.os_disk.lz_key, var.client_config.landingzone_key)][var.settings.virtual_machine_settings.windows.os_disk.disk_encryption_set_key].id : null
  }

  dynamic "managed_disk" {
    for_each = lookup(var.settings, "data_disks", {})
    content {
      disk_id = replace(replace(lower(var.virtual_machine_data_disks[managed_disk.key]), "microsoft.compute", "Microsoft.Compute"), "resourcegroups", "resourceGroups")

      staging_storage_account_id = coalesce(
        try(var.storage_accounts[var.client_config.landingzone_key][var.settings.replication.staging_storage_account_key].id, null),
        try(var.storage_accounts[var.settings.replication.staging_storage_account.lz_key][var.settings.replication.staging_storage_account.key].id, null)
      )
      target_resource_group_id = coalesce(
        try(var.resource_groups[var.client_config.landingzone_key][var.settings.replication.target.resource_group_key].id, null),
        try(var.recovery_vaults[var.settings.replication.target.resource_group.lz_key][var.settings.replication.resource_group.key].id, null)
      )

      target_disk_type              = try(var.settings.replication.target.data_disk_storage_type, managed_disk.value.storage_account_type)
      target_replica_disk_type      = try(var.settings.replication.target.data_disk_replica_storage_type, var.settings.replication.target.data_disk_storage_type, managed_disk.value.storage_account_type)
      target_disk_encryption_set_id = try(managed_disk.value.disk_encryption_set_key, null) == null ? null : var.disk_encryption_sets[try(managed_disk.value.lz_key, var.client_config.landingzone_key)][managed_disk.value.disk_encryption_set_key].id
    }
  }

  dynamic "network_interface" {
    for_each = local.normalized_network_interfaces
    content {
      source_network_interface_id = network_interface.value.source_network_interface_id

      dynamic "ip_configuration" {
        for_each = try(network_interface.value.ip_configurations, [])
        content {
          name                                            = ip_configuration.value.name
          target_subnet_name                              = try(ip_configuration.value.target_subnet_name, local.replication_target_subnet_name)
          failover_test_subnet_name                       = try(ip_configuration.value.failover_test_subnet_name, local.replication_test_subnet_name)
          target_static_ip                                = try(ip_configuration.value.target_static_ip, null)
          failover_test_static_ip                         = try(ip_configuration.value.failover_test_static_ip, null)
          recovery_public_ip_address_id                   = try(ip_configuration.value.recovery_public_ip_address_id, null)
          failover_test_public_ip_address_id              = try(ip_configuration.value.failover_test_public_ip_address_id, null)
          recovery_load_balancer_backend_address_pool_ids = try(ip_configuration.value.recovery_load_balancer_backend_address_pool_ids, null)
        }
      }
    }
  }

  timeouts {
    create = "24h"
  }
}
