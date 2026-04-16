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
  description = "The name of the resource group in which to create the Route Table."
  type        = string
}

variable "location" {
  description = "The Azure region where the Route Table will be created."
  type        = string
}

# -------------------------------------------------------
# BGP Route Propagation
# -------------------------------------------------------

variable "bgp_route_propagation_enabled" {
  description = "When true, routes learned via BGP are propagated to the route table. Defaults to false to prevent unintended routing in hub-and-spoke topologies."
  type        = bool
  default     = false
}

# -------------------------------------------------------
# Routes
# -------------------------------------------------------

variable "routes" {
  description = <<-EOT
    A list of routes to create within the Route Table.

    Each object supports:
      name                  - (Required) A unique name for the route.
      address_prefix        - (Required) The destination CIDR block this route applies to (e.g. "0.0.0.0/0").
      next_hop_type         - (Required) The type of next hop. Must be one of: "VirtualNetworkGateway", "VnetLocal", "Internet", "VirtualAppliance", "None".
      next_hop_in_ip_address - (Optional) The IP address of the next hop. Required when next_hop_type is "VirtualAppliance".
  EOT
  type = list(object({
    name                  = string
    address_prefix        = string
    next_hop_type         = string
    next_hop_in_ip_address = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for route in var.routes : contains(["VirtualNetworkGateway", "VnetLocal", "Internet", "VirtualAppliance", "None"], route.next_hop_type)
    ])
    error_message = "Each route next_hop_type must be one of: \"VirtualNetworkGateway\", \"VnetLocal\", \"Internet\", \"VirtualAppliance\", \"None\"."
  }

  validation {
    condition = alltrue([
      for route in var.routes : route.next_hop_type != "VirtualAppliance" || (route.next_hop_in_ip_address != null && route.next_hop_in_ip_address != "")
    ])
    error_message = "next_hop_in_ip_address is required when next_hop_type is \"VirtualAppliance\"."
  }

  validation {
    condition = alltrue([
      for route in var.routes : can(cidrhost(route.address_prefix, 0))
    ])
    error_message = "Each route address_prefix must be valid CIDR notation (e.g. \"0.0.0.0/0\")."
  }
}

# -------------------------------------------------------
# Tagging
# -------------------------------------------------------

variable "tags" {
  description = "A map of tags to assign to the Route Table."
  type        = map(string)
  default = {
    terraformDeployed = "true"
  }
}
