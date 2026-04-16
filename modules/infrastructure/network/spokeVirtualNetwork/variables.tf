# -------------------------------------------------------
# Required
# -------------------------------------------------------

# Adding a comment to trigger pipeline

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
  description = "The name of the resource group in which all spoke network resources will be created."
  type        = string
}

variable "location" {
  description = "The Azure region where all spoke network resources will be created."
  type        = string
}

variable "address_space" {
  description = "A list of CIDR blocks that define the address space of the spoke Virtual Network (e.g. [\"10.1.0.0/16\"])."
  type        = list(string)

  validation {
    condition = alltrue([
      for cidr in var.address_space : can(cidrhost(cidr, 0))
    ])
    error_message = "All entries in address_space must be valid CIDR notation (e.g. \"10.1.0.0/16\")."
  }
}

# -------------------------------------------------------
# Virtual Network — Optional
# -------------------------------------------------------

variable "dns_servers" {
  description = "A list of custom DNS server IP addresses for the spoke Virtual Network. When empty, Azure-provided DNS is used."
  type        = list(string)
  default     = []
}

variable "flow_timeout_in_minutes" {
  description = "The flow timeout in minutes for the spoke Virtual Network. Must be between 4 and 30. When null, the Azure default applies."
  type        = number
  default     = null

  validation {
    condition     = var.flow_timeout_in_minutes == null || (var.flow_timeout_in_minutes >= 4 && var.flow_timeout_in_minutes <= 30)
    error_message = "flow_timeout_in_minutes must be between 4 and 30."
  }
}

# -------------------------------------------------------
# Network Security Groups
# -------------------------------------------------------

variable "network_security_groups" {
  description = <<-EOT
    A map of Network Security Groups to create. The map key is used as a short identifier (e.g. "aca", "pe", "mgmt")
    and is appended to application_purpose when naming the resource (e.g. "payments-aca").

    Each object supports:
      security_rules - (Optional) List of security rules. See the networkSecurityGroup resource module for the full rule schema.

    Example:
      network_security_groups = {
        aca = {
          security_rules = [
            {
              name                         = "allow-https-inbound"
              priority                     = 100
              direction                    = "Inbound"
              access                       = "Allow"
              protocol                     = "Tcp"
              source_port_ranges           = ["*"]
              source_address_prefixes      = ["10.0.0.0/8"]
              destination_port_ranges      = ["443"]
              destination_address_prefixes = ["*"]
            }
          ]
        }
      }
  EOT
  type = map(object({
    security_rules = optional(list(object({
      name                         = string
      priority                     = number
      direction                    = string
      access                       = string
      protocol                     = string
      source_port_ranges           = list(string)
      source_address_prefixes      = list(string)
      destination_port_ranges      = list(string)
      destination_address_prefixes = list(string)
    })), [])
  }))
  default = {}
}

# -------------------------------------------------------
# Route Tables
# -------------------------------------------------------

variable "route_tables" {
  description = <<-EOT
    A map of Route Tables to create. The map key is used as a short identifier (e.g. "aca", "default")
    and is appended to application_purpose when naming the resource.

    Each object supports:
      bgp_route_propagation_enabled - (Optional) Whether BGP routes are propagated. Defaults to false.
      routes                        - (Optional) List of routes. See the routeTable resource module for the full route schema.

    Example:
      route_tables = {
        aca = {
          routes = [
            {
              name           = "default-to-firewall"
              address_prefix = "0.0.0.0/0"
              next_hop_type  = "VirtualAppliance"
              next_hop_in_ip_address = "10.0.0.4"
            }
          ]
        }
      }
  EOT
  type = map(object({
    bgp_route_propagation_enabled = optional(bool, false)
    routes = optional(list(object({
      name                   = string
      address_prefix         = string
      next_hop_type          = string
      next_hop_in_ip_address = optional(string)
    })), [])
  }))
  default = {}
}

# -------------------------------------------------------
# Subnets
# -------------------------------------------------------

variable "subnets" {
  description = <<-EOT
    A map of subnets to create within the spoke Virtual Network. The map key is used as a short identifier
    (e.g. "aca", "pe", "mgmt") and is appended to application_purpose when naming the subnet.

    Each object supports:
      address_prefixes                              - (Required) CIDR blocks for the subnet.
      service_endpoints                             - (Optional) Service endpoints to enable. Defaults to [].
      private_endpoint_network_policies             - (Optional) Network policy mode for private endpoints. Defaults to "Disabled".
      private_link_service_network_policies_enabled - (Optional) Enable network policies for private link service NICs. Defaults to false.
      default_outbound_access_enabled               - (Optional) Allow default outbound internet access. Defaults to false.
      nsg_key                                       - (Optional) Key from network_security_groups to associate with this subnet.
      route_table_key                               - (Optional) Key from route_tables to associate with this subnet.
      delegation                                    - (Optional) Service delegation block.

    Example:
      subnets = {
        aca = {
          address_prefixes = ["10.1.1.0/24"]
          nsg_key          = "aca"
          route_table_key  = "aca"
          delegation = {
            name         = "aca-delegation"
            service_name = "Microsoft.App/environments"
          }
        }
        pe = {
          address_prefixes                  = ["10.1.2.0/24"]
          nsg_key                           = "pe"
          private_endpoint_network_policies = "Enabled"
        }
      }
  EOT
  type = map(object({
    address_prefixes                              = list(string)
    service_endpoints                             = optional(list(string), [])
    private_endpoint_network_policies             = optional(string, "Disabled")
    private_link_service_network_policies_enabled = optional(bool, false)
    default_outbound_access_enabled               = optional(bool, false)
    nsg_key                                       = optional(string)
    route_table_key                               = optional(string)
    delegation = optional(object({
      name            = string
      service_name    = string
      service_actions = optional(list(string), [])
    }))
  }))

  validation {
    condition = alltrue([
      for k, s in var.subnets : alltrue([
        for cidr in s.address_prefixes : can(cidrhost(cidr, 0))
      ])
    ])
    error_message = "All subnet address_prefixes must be valid CIDR notation."
  }
}

# -------------------------------------------------------
# Hub Peering
# -------------------------------------------------------

variable "hub_peering" {
  description = <<-EOT
    Configuration for the Virtual Network Peering from this spoke to the hub Virtual Network.

    Each object supports:
      remote_virtual_network_id    - (Required) The full resource ID of the hub Virtual Network.
      allow_forwarded_traffic      - (Optional) Allow forwarded traffic through this peering. Defaults to true.
      allow_gateway_transit        - (Optional) Allow gateway transit. Defaults to false (spoke side).
      use_remote_gateways          - (Optional) Use the hub's gateway. Defaults to false.
      allow_virtual_network_access - (Optional) Allow cross-VNet resource access. Defaults to true.

    Example:
      hub_peering = {
        remote_virtual_network_id = "/subscriptions/.../virtualNetworks/vnet-hub-prod-uks"
      }
  EOT
  type = object({
    remote_virtual_network_id    = string
    allow_forwarded_traffic      = optional(bool, true)
    allow_gateway_transit        = optional(bool, false)
    use_remote_gateways          = optional(bool, false)
    allow_virtual_network_access = optional(bool, true)
  })

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.Network/virtualNetworks/[^/]+$", var.hub_peering.remote_virtual_network_id))
    error_message = "hub_peering.remote_virtual_network_id must be a valid Azure Virtual Network resource ID."
  }
}

# -------------------------------------------------------
# Tagging
# -------------------------------------------------------

variable "tags" {
  description = "A map of tags to assign to all resources in the spoke Virtual Network."
  type        = map(string)
  default = {
    terraformDeployed = "true"
  }
}
