output "id" {
  description = "The resource ID of the Virtual Network."
  value       = azurerm_virtual_network.this.id
}

output "name" {
  description = "The name of the Virtual Network."
  value       = azurerm_virtual_network.this.name
}

output "guid" {
  description = "The GUID of the Virtual Network."
  value       = azurerm_virtual_network.this.guid
}

output "location" {
  description = "The Azure region where the Virtual Network is deployed."
  value       = azurerm_virtual_network.this.location
}
