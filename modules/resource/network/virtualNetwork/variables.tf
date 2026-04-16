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
  description = "The name of the resource group in which to create the Virtual Network."
  type        = string
}

variable "location" {
  description = "The Azure region where the Virtual Network will be created."
  type        = string
}

variable "address_space" {
  description = "A list of CIDR blocks that define the address space of the Virtual Network (e.g. [\"10.0.0.0/16\"])."
  type        = list(string)

  validation {
    condition = alltrue([
      for cidr in var.address_space : can(cidrhost(cidr, 0))
    ])
    error_message = "All entries in address_space must be valid CIDR notation (e.g. \"10.0.0.0/16\")."
  }
}

# -------------------------------------------------------
# DNS
# -------------------------------------------------------

variable "dns_servers" {
  description = "A list of custom DNS server IP addresses for the Virtual Network. When empty, Azure-provided DNS is used."
  type        = list(string)
  default     = []
}

# -------------------------------------------------------
# Flow Timeout
# -------------------------------------------------------

variable "flow_timeout_in_minutes" {
  description = "The flow timeout in minutes for the Virtual Network. Must be between 4 and 30. When null, the Azure default applies."
  type        = number
  default     = null

  validation {
    condition     = var.flow_timeout_in_minutes == null || (var.flow_timeout_in_minutes >= 4 && var.flow_timeout_in_minutes <= 30)
    error_message = "flow_timeout_in_minutes must be between 4 and 30."
  }
}

# -------------------------------------------------------
# Tagging
# -------------------------------------------------------

variable "tags" {
  description = "A map of tags to assign to the Virtual Network."
  type        = map(string)
  default = {
    terraformDeployed = "true"
  }
}
