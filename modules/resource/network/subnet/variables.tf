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
  description = "The name of the resource group in which the parent Virtual Network resides."
  type        = string
}

variable "virtual_network_name" {
  description = "The name of the Virtual Network in which to create the subnet."
  type        = string
}

variable "address_prefixes" {
  description = "A list of CIDR blocks to assign to the subnet (e.g. [\"10.0.1.0/24\"]). Must fall within the parent Virtual Network address space."
  type        = list(string)

  validation {
    condition = alltrue([
      for cidr in var.address_prefixes : can(cidrhost(cidr, 0))
    ])
    error_message = "All entries in address_prefixes must be valid CIDR notation (e.g. \"10.0.1.0/24\")."
  }
}

# -------------------------------------------------------
# Service Endpoints
# -------------------------------------------------------

variable "service_endpoints" {
  description = "A list of service endpoints to enable on the subnet (e.g. [\"Microsoft.Storage\", \"Microsoft.KeyVault\"])."
  type        = list(string)
  default     = []
}

# -------------------------------------------------------
# Private Endpoint / Private Link
# -------------------------------------------------------

variable "private_endpoint_network_policies" {
  description = "Controls network policies on private endpoint NICs within this subnet. Valid values are \"Disabled\", \"Enabled\", \"NetworkSecurityGroupEnabled\", \"RouteTableEnabled\"."
  type        = string
  default     = "Disabled"

  validation {
    condition     = contains(["Disabled", "Enabled", "NetworkSecurityGroupEnabled", "RouteTableEnabled"], var.private_endpoint_network_policies)
    error_message = "private_endpoint_network_policies must be one of: \"Disabled\", \"Enabled\", \"NetworkSecurityGroupEnabled\", \"RouteTableEnabled\"."
  }
}

variable "private_link_service_network_policies_enabled" {
  description = "When true, network policies are applied to the private link service NIC in this subnet."
  type        = bool
  default     = false
}

# -------------------------------------------------------
# Outbound Access
# -------------------------------------------------------

variable "default_outbound_access_enabled" {
  description = "When true, default outbound internet access is enabled for resources in this subnet. Defaults to false in line with Azure's recommended security posture."
  type        = bool
  default     = false
}

# -------------------------------------------------------
# Associations
# -------------------------------------------------------

variable "network_security_group_id" {
  description = "The resource ID of the Network Security Group to associate with this subnet. When null, no NSG association is created."
  type        = string
  default     = null

  validation {
    condition     = var.network_security_group_id == null || can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.Network/networkSecurityGroups/[^/]+$", var.network_security_group_id))
    error_message = "network_security_group_id must be a valid Azure Network Security Group resource ID."
  }
}

variable "route_table_id" {
  description = "The resource ID of the Route Table to associate with this subnet. When null, no route table association is created."
  type        = string
  default     = null

  validation {
    condition     = var.route_table_id == null || can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.Network/routeTables/[^/]+$", var.route_table_id))
    error_message = "route_table_id must be a valid Azure Route Table resource ID."
  }
}

# -------------------------------------------------------
# Delegation
# -------------------------------------------------------

variable "delegation" {
  description = <<-EOT
    Optional service delegation block for the subnet. Required when the subnet is used by a managed service such as Azure Container Apps.

    Each object supports:
      name            - (Required) A name for the delegation (e.g. "aca-delegation").
      service_name    - (Required) The service to delegate to (e.g. "Microsoft.App/environments").
      service_actions - (Optional) List of actions permitted to the delegated service. Defaults to [] which lets Azure apply the correct actions automatically.

    Example — delegating to Azure Container Apps:
      delegation = {
        name         = "aca-delegation"
        service_name = "Microsoft.App/environments"
      }
  EOT
  type = object({
    name            = string
    service_name    = string
    service_actions = optional(list(string), [])
  })
  default = null
}
