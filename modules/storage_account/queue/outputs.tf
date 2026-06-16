output "id" {
  description = "The ID of the Storage Queue."
  value       = azurerm_storage_queue.queue.id
}

output "url" {
  description = "The URL of the Storage Queue."
  value       = azurerm_storage_queue.queue.url
}
