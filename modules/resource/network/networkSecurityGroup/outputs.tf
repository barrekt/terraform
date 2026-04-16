output "id" {
  description = "The resource ID of the Network Security Group."
  value       = azurerm_network_security_group.this.id
}

output "name" {
  description = "The name of the Network Security Group."
  value       = azurerm_network_security_group.this.name
}
