output "id" {
  description = "The resource ID of the Virtual Network Peering."
  value       = azurerm_virtual_network_peering.this.id
}

output "name" {
  description = "The name of the Virtual Network Peering."
  value       = azurerm_virtual_network_peering.this.name
}
