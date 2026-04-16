resource "azurerm_container_app_environment" "this" {
  name                = "cae-${var.application_purpose}-${var.environment}-${var.region}"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Logging
  log_analytics_workspace_id                  = var.log_analytics_workspace_id
  dapr_application_insights_connection_string = var.dapr_application_insights_connection_string

  # Networking
  infrastructure_subnet_id           = var.infrastructure_subnet_id
  infrastructure_resource_group_name = var.infrastructure_resource_group_name
  internal_load_balancer_enabled     = var.internal_load_balancer_enabled

  # Resiliency & Security
  zone_redundancy_enabled = var.zone_redundancy_enabled
  mutual_tls_enabled      = var.mutual_tls_enabled

  # Workload Profiles
  dynamic "workload_profile" {
    for_each = var.workload_profiles
    content {
      name                  = workload_profile.value.name
      workload_profile_type = workload_profile.value.workload_profile_type
      minimum_count         = workload_profile.value.minimum_count
      maximum_count         = workload_profile.value.maximum_count
    }
  }

  tags = var.tags
}
