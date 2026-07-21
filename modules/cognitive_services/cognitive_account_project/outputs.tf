output "id" {
  description = "The ID of the Cognitive Account Project."
  value       = azurerm_cognitive_account_project.project.id
}

output "default" {
  description = "Whether this project is the default project for the Cognitive Account."
  value       = azurerm_cognitive_account_project.project.default
}

output "endpoints" {
  description = "A mapping of endpoint names to endpoint URLs for the project."
  value       = azurerm_cognitive_account_project.project.endpoints
}

output "identity" {
  description = "An identity block as defined below."
  value       = azurerm_cognitive_account_project.project.identity
}
