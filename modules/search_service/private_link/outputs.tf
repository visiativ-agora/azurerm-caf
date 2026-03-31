output "id" {
  description = "The ID of the Azure Search Shared Private Link resource."
  value       = azurerm_search_shared_private_link_service.search_service_shared_private_link_service.id
}

output "status" {
  description = "The status of a private endpoint connection. Possible values are Pending, Approved, Rejected or Disconnected."
  value       = azurerm_search_shared_private_link_service.search_service_shared_private_link_service.status
}