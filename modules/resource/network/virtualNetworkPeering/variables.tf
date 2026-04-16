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
  description = "The name of the resource group containing the local Virtual Network."
  type        = string
}

variable "virtual_network_name" {
  description = "The name of the local Virtual Network from which this peering link originates."
  type        = string
}

variable "remote_virtual_network_id" {
  description = "The full resource ID of the remote Virtual Network to peer with. Supports cross-subscription peering."
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.Network/virtualNetworks/[^/]+$", var.remote_virtual_network_id))
    error_message = "remote_virtual_network_id must be a valid Azure Virtual Network resource ID."
  }
}

# -------------------------------------------------------
# Peering Options
# -------------------------------------------------------

variable "allow_forwarded_traffic" {
  description = "When true, forwarded traffic originating outside the local Virtual Network is allowed through this peering. Required when routing through a hub firewall."
  type        = bool
  default     = true
}

variable "allow_gateway_transit" {
  description = "When true, the local Virtual Network can use its gateway to provide transit to the remote Virtual Network. Typically enabled on the hub side of a hub-and-spoke topology."
  type        = bool
  default     = false
}

variable "use_remote_gateways" {
  description = "When true, traffic from the local Virtual Network uses the gateway in the remote Virtual Network. Requires the remote VNet to have allow_gateway_transit enabled. Typically enabled on spoke side."
  type        = bool
  default     = false
}

variable "allow_virtual_network_access" {
  description = "When true, resources in the remote Virtual Network can access resources in the local Virtual Network."
  type        = bool
  default     = true
}
