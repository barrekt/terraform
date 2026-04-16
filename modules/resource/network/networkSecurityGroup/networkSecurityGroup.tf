resource "azurerm_network_security_group" "this" {
  name                = "nsg-${var.application_purpose}-${var.environment}-${var.region}"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_network_security_rule" "this" {
  for_each = { for rule in var.security_rules : rule.name => rule }

  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.this.name

  source_port_range  = each.value.source_port_ranges == ["*"] ? "*" : null
  source_port_ranges = each.value.source_port_ranges == ["*"] ? null : each.value.source_port_ranges

  source_address_prefix   = length(each.value.source_address_prefixes) == 1 ? each.value.source_address_prefixes[0] : null
  source_address_prefixes = length(each.value.source_address_prefixes) > 1 ? each.value.source_address_prefixes : null

  destination_port_range  = each.value.destination_port_ranges == ["*"] ? "*" : null
  destination_port_ranges = each.value.destination_port_ranges == ["*"] ? null : each.value.destination_port_ranges

  destination_address_prefix   = length(each.value.destination_address_prefixes) == 1 ? each.value.destination_address_prefixes[0] : null
  destination_address_prefixes = length(each.value.destination_address_prefixes) > 1 ? each.value.destination_address_prefixes : null
}
