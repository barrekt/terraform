# -------------------------------------------------------
# Required
# -------------------------------------------------------

variable "application_purpose" {
  description = "The purpose or workload name for this deployment, used as part of the resource naming convention (e.g. \"payments\", \"api\", \"frontend\")."
  type        = string
}

variable "environment" {
  description = "The deployment environment, used as part of the resource naming convention (e.g. \"dev\", \"staging\", \"prod\")."
  type        = string
}

variable "region" {
  description = "The region abbreviation, used as part of the resource naming convention (e.g. \"uks\", \"euw\", \"eus\")."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Container Apps Environment."
  type        = string
}

variable "location" {
  description = "The Azure region where the Container Apps Environment will be created."
  type        = string
}

# -------------------------------------------------------
# Logging
# -------------------------------------------------------

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace to link to the Container Apps Environment for diagnostics."
  type        = string
  default     = null

  validation {
    condition     = var.log_analytics_workspace_id == null || can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.OperationalInsights/workspaces/[^/]+$", var.log_analytics_workspace_id))
    error_message = "log_analytics_workspace_id must be a valid Azure Log Analytics Workspace resource ID in the format: /subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.OperationalInsights/workspaces/{name}."
  }
}

variable "dapr_application_insights_connection_string" {
  description = "Application Insights connection string used for Dapr telemetry. Marked sensitive to prevent exposure in plan output."
  type        = string
  default     = null
  sensitive   = true
}

# -------------------------------------------------------
# Networking
# -------------------------------------------------------

variable "infrastructure_subnet_id" {
  description = "The ID of the subnet to use for the managed infrastructure. Must be delegated to Microsoft.App/environments."
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.Network/virtualNetworks/[^/]+/subnets/[^/]+$", var.infrastructure_subnet_id))
    error_message = "infrastructure_subnet_id must be a valid Azure subnet resource ID in the format: /subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Network/virtualNetworks/{vnet}/subnets/{subnet}. Company standards require all Container Apps Environments to be VNet-integrated."
  }
}

variable "infrastructure_resource_group_name" {
  description = "The name of the resource group that will be created to hold the managed infrastructure resources (e.g. internal load balancer). Defaults to a platform-generated name when not set."
  type        = string
  default     = null
}

variable "internal_load_balancer_enabled" {
  description = "When true the environment is deployed with an internal-only load balancer and public network access is disabled. Defaults to true as per organisational standards."
  type        = bool
  default     = true
}

# -------------------------------------------------------
# Resiliency & Security
# -------------------------------------------------------

variable "zone_redundancy_enabled" {
  description = "When true the environment is deployed across availability zones. Defaults to true as per organisational standards — no additional cost is incurred."
  type        = bool
  default     = true
}

variable "mutual_tls_enabled" {
  description = "When true, mutual TLS (mTLS) is enforced for all service-to-service communication within the environment."
  type        = bool
  default     = false
}

# -------------------------------------------------------
# Workload Profiles
# -------------------------------------------------------

variable "workload_profiles" {
  description = <<-EOT
    List of workload profile blocks to configure on the environment.

    Each object supports:
      name                  - (Required) Unique name for the workload profile.
      workload_profile_type - (Required) The SKU type. Use "Consumption" for serverless or a
                              dedicated SKU such as "D4", "D8", "D16", "D32", "E4", "E8",
                              "E16", "E32", "NC24-A100", etc.
      minimum_count         - (Optional) Minimum number of instances. Not applicable to Consumption profiles.
      maximum_count         - (Optional) Maximum number of instances. Not applicable to Consumption profiles.

    Example — mixed Consumption + dedicated profile:
      workload_profiles = [
        {
          name                  = "Consumption"
          workload_profile_type = "Consumption"
        },
        {
          name                  = "dedicated-d4"
          workload_profile_type = "D4"
          minimum_count         = 3
          maximum_count         = 10
        }
      ]
  EOT
  type = list(object({
    name                  = string
    workload_profile_type = string
    minimum_count         = optional(number)
    maximum_count         = optional(number)
  }))
  default = [
    {
      name                  = "Consumption"
      workload_profile_type = "Consumption"
      minimum_count         = 0
      maximum_count         = 0
    }
  ]

  validation {
    condition = alltrue([
      for p in var.workload_profiles :
      p.workload_profile_type == "Consumption" || (
        p.minimum_count != null && p.minimum_count >= 3 &&
        p.maximum_count != null && p.maximum_count <= 100 &&
        p.maximum_count >= p.minimum_count
      )
    ])
    error_message = "Dedicated workload profiles must have a minimum_count of at least 3, a maximum_count no greater than 100, and maximum_count must be greater than or equal to minimum_count."
  }
}

# -------------------------------------------------------
# Tagging
# -------------------------------------------------------

variable "tags" {
  description = "A map of tags to assign to the Container Apps Environment."
  type        = map(string)
  default = {
    terraformDeployed = "true"
  }
}
