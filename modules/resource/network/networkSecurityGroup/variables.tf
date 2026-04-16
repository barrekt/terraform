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
  description = "The name of the resource group in which to create the Network Security Group."
  type        = string
}

variable "location" {
  description = "The Azure region where the Network Security Group will be created."
  type        = string
}

# -------------------------------------------------------
# Security Rules
# -------------------------------------------------------

variable "security_rules" {
  description = <<-EOT
    A list of security rules to create within the Network Security Group.

    Each object supports:
      name                        - (Required) A unique name for the rule.
      priority                    - (Required) The priority of the rule. Must be between 100 and 4096.
      direction                   - (Required) The direction of traffic. Must be "Inbound" or "Outbound".
      access                      - (Required) Whether traffic is allowed or denied. Must be "Allow" or "Deny".
      protocol                    - (Required) The network protocol. Must be "Tcp", "Udp", "Icmp", "Esp", "Ah", or "*".
      source_port_ranges          - (Required) List of source port ranges. Use ["*"] for all ports.
      source_address_prefixes     - (Required) List of source address prefixes or service tags.
      destination_port_ranges     - (Required) List of destination port ranges. Use ["*"] for all ports.
      destination_address_prefixes - (Required) List of destination address prefixes or service tags.
  EOT
  type = list(object({
    name                         = string
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    source_port_ranges           = list(string)
    source_address_prefixes      = list(string)
    destination_port_ranges      = list(string)
    destination_address_prefixes = list(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.security_rules : contains(["Inbound", "Outbound"], rule.direction)
    ])
    error_message = "Each rule direction must be \"Inbound\" or \"Outbound\"."
  }

  validation {
    condition = alltrue([
      for rule in var.security_rules : contains(["Allow", "Deny"], rule.access)
    ])
    error_message = "Each rule access must be \"Allow\" or \"Deny\"."
  }

  validation {
    condition = alltrue([
      for rule in var.security_rules : contains(["Tcp", "Udp", "Icmp", "Esp", "Ah", "*"], rule.protocol)
    ])
    error_message = "Each rule protocol must be one of: \"Tcp\", \"Udp\", \"Icmp\", \"Esp\", \"Ah\", \"*\"."
  }

  validation {
    condition = alltrue([
      for rule in var.security_rules : rule.priority >= 100 && rule.priority <= 4096
    ])
    error_message = "Each rule priority must be between 100 and 4096."
  }
}

# -------------------------------------------------------
# Tagging
# -------------------------------------------------------

variable "tags" {
  description = "A map of tags to assign to the Network Security Group."
  type        = map(string)
  default = {
    terraformDeployed = "true"
  }
}
