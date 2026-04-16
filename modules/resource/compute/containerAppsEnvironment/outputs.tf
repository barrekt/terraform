output "id" {
  description = "The resource ID of the Container Apps Environment."
  value       = azurerm_container_app_environment.this.id
}

output "name" {
  description = "The name of the Container Apps Environment."
  value       = azurerm_container_app_environment.this.name
}

output "default_domain" {
  description = "The default domain suffix of the Container Apps Environment, used to construct FQDNs for apps within it."
  value       = azurerm_container_app_environment.this.default_domain
}

output "static_ip_address" {
  description = "The static IP address associated with the Container Apps Environment. For internal environments this will be a private IP."
  value       = azurerm_container_app_environment.this.static_ip_address
}

output "docker_bridge_cidr" {
  description = "The CIDR block of the Docker bridge network used by the environment."
  value       = azurerm_container_app_environment.this.docker_bridge_cidr
}

output "platform_reserved_cidr" {
  description = "The IP range reserved for the Azure platform within the environment's VNet integration."
  value       = azurerm_container_app_environment.this.platform_reserved_cidr
}

output "platform_reserved_dns_ip_address" {
  description = "The DNS server IP address reserved for the Azure platform within the environment's VNet integration."
  value       = azurerm_container_app_environment.this.platform_reserved_dns_ip_address
}
