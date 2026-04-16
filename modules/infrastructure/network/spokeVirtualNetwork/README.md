# spokeVirtualNetwork

Provisions a complete spoke Virtual Network for a hub-and-spoke topology, composing a Virtual Network, one-to-many subnets with optional NSG and route table associations, and a single outbound peering link to a hub Virtual Network.


![spokeVirtualNetwork.png](spoke-virtual-network.png)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.9 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_hub_peering"></a> [hub\_peering](#module\_hub\_peering) | ../../../resource/network/virtualNetworkPeering | n/a |
| <a name="module_network_security_groups"></a> [network\_security\_groups](#module\_network\_security\_groups) | ../../../resource/network/networkSecurityGroup | n/a |
| <a name="module_route_tables"></a> [route\_tables](#module\_route\_tables) | ../../../resource/network/routeTable | n/a |
| <a name="module_subnets"></a> [subnets](#module\_subnets) | ../../../resource/network/subnet | n/a |
| <a name="module_virtual_network"></a> [virtual\_network](#module\_virtual\_network) | ../../../resource/network/virtualNetwork | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | A list of CIDR blocks that define the address space of the spoke Virtual Network (e.g. ["10.1.0.0/16"]). | `list(string)` | n/a | yes |
| <a name="input_application_purpose"></a> [application\_purpose](#input\_application\_purpose) | The purpose or workload name for this deployment, used as part of the resource naming convention (e.g. "payments", "api", "frontend"). | `string` | n/a | yes |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | A list of custom DNS server IP addresses for the spoke Virtual Network. When empty, Azure-provided DNS is used. | `list(string)` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The deployment environment, used as part of the resource naming convention (e.g. "dev", "staging", "prod"). | `string` | n/a | yes |
| <a name="input_flow_timeout_in_minutes"></a> [flow\_timeout\_in\_minutes](#input\_flow\_timeout\_in\_minutes) | The flow timeout in minutes for the spoke Virtual Network. Must be between 4 and 30. When null, the Azure default applies. | `number` | `null` | no |
| <a name="input_hub_peering"></a> [hub\_peering](#input\_hub\_peering) | Configuration for the Virtual Network Peering from this spoke to the hub Virtual Network.<br/><br/>Each object supports:<br/>  remote\_virtual\_network\_id    - (Required) The full resource ID of the hub Virtual Network.<br/>  allow\_forwarded\_traffic      - (Optional) Allow forwarded traffic through this peering. Defaults to true.<br/>  allow\_gateway\_transit        - (Optional) Allow gateway transit. Defaults to false (spoke side).<br/>  use\_remote\_gateways          - (Optional) Use the hub's gateway. Defaults to false.<br/>  allow\_virtual\_network\_access - (Optional) Allow cross-VNet resource access. Defaults to true.<br/><br/>Example:<br/>  hub\_peering = {<br/>    remote\_virtual\_network\_id = "/subscriptions/.../virtualNetworks/vnet-hub-prod-uks"<br/>  } | <pre>object({<br/>    remote_virtual_network_id    = string<br/>    allow_forwarded_traffic      = optional(bool, true)<br/>    allow_gateway_transit        = optional(bool, false)<br/>    use_remote_gateways          = optional(bool, false)<br/>    allow_virtual_network_access = optional(bool, true)<br/>  })</pre> | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where all spoke network resources will be created. | `string` | n/a | yes |
| <a name="input_network_security_groups"></a> [network\_security\_groups](#input\_network\_security\_groups) | A map of Network Security Groups to create. The map key is used as a short identifier (e.g. "aca", "pe", "mgmt")<br/>and is appended to application\_purpose when naming the resource (e.g. "payments-aca").<br/><br/>Each object supports:<br/>  security\_rules - (Optional) List of security rules. See the networkSecurityGroup resource module for the full rule schema.<br/><br/>Example:<br/>  network\_security\_groups = {<br/>    aca = {<br/>      security\_rules = [<br/>        {<br/>          name                         = "allow-https-inbound"<br/>          priority                     = 100<br/>          direction                    = "Inbound"<br/>          access                       = "Allow"<br/>          protocol                     = "Tcp"<br/>          source\_port\_ranges           = ["*"]<br/>          source\_address\_prefixes      = ["10.0.0.0/8"]<br/>          destination\_port\_ranges      = ["443"]<br/>          destination\_address\_prefixes = ["*"]<br/>        }<br/>      ]<br/>    }<br/>  } | <pre>map(object({<br/>    security_rules = optional(list(object({<br/>      name                         = string<br/>      priority                     = number<br/>      direction                    = string<br/>      access                       = string<br/>      protocol                     = string<br/>      source_port_ranges           = list(string)<br/>      source_address_prefixes      = list(string)<br/>      destination_port_ranges      = list(string)<br/>      destination_address_prefixes = list(string)<br/>    })), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_region"></a> [region](#input\_region) | The region abbreviation, used as part of the resource naming convention (e.g. "uks", "euw", "eus"). | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which all spoke network resources will be created. | `string` | n/a | yes |
| <a name="input_route_tables"></a> [route\_tables](#input\_route\_tables) | A map of Route Tables to create. The map key is used as a short identifier (e.g. "aca", "default")<br/>and is appended to application\_purpose when naming the resource.<br/><br/>Each object supports:<br/>  bgp\_route\_propagation\_enabled - (Optional) Whether BGP routes are propagated. Defaults to false.<br/>  routes                        - (Optional) List of routes. See the routeTable resource module for the full route schema.<br/><br/>Example:<br/>  route\_tables = {<br/>    aca = {<br/>      routes = [<br/>        {<br/>          name           = "default-to-firewall"<br/>          address\_prefix = "0.0.0.0/0"<br/>          next\_hop\_type  = "VirtualAppliance"<br/>          next\_hop\_in\_ip\_address = "10.0.0.4"<br/>        }<br/>      ]<br/>    }<br/>  } | <pre>map(object({<br/>    bgp_route_propagation_enabled = optional(bool, false)<br/>    routes = optional(list(object({<br/>      name                   = string<br/>      address_prefix         = string<br/>      next_hop_type          = string<br/>      next_hop_in_ip_address = optional(string)<br/>    })), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | A map of subnets to create within the spoke Virtual Network. The map key is used as a short identifier<br/>(e.g. "aca", "pe", "mgmt") and is appended to application\_purpose when naming the subnet.<br/><br/>Each object supports:<br/>  address\_prefixes                              - (Required) CIDR blocks for the subnet.<br/>  service\_endpoints                             - (Optional) Service endpoints to enable. Defaults to [].<br/>  private\_endpoint\_network\_policies             - (Optional) Network policy mode for private endpoints. Defaults to "Disabled".<br/>  private\_link\_service\_network\_policies\_enabled - (Optional) Enable network policies for private link service NICs. Defaults to false.<br/>  default\_outbound\_access\_enabled               - (Optional) Allow default outbound internet access. Defaults to false.<br/>  nsg\_key                                       - (Optional) Key from network\_security\_groups to associate with this subnet.<br/>  route\_table\_key                               - (Optional) Key from route\_tables to associate with this subnet.<br/>  delegation                                    - (Optional) Service delegation block.<br/><br/>Example:<br/>  subnets = {<br/>    aca = {<br/>      address\_prefixes = ["10.1.1.0/24"]<br/>      nsg\_key          = "aca"<br/>      route\_table\_key  = "aca"<br/>      delegation = {<br/>        name         = "aca-delegation"<br/>        service\_name = "Microsoft.App/environments"<br/>      }<br/>    }<br/>    pe = {<br/>      address\_prefixes                  = ["10.1.2.0/24"]<br/>      nsg\_key                           = "pe"<br/>      private\_endpoint\_network\_policies = "Enabled"<br/>    }<br/>  } | <pre>map(object({<br/>    address_prefixes                              = list(string)<br/>    service_endpoints                             = optional(list(string), [])<br/>    private_endpoint_network_policies             = optional(string, "Disabled")<br/>    private_link_service_network_policies_enabled = optional(bool, false)<br/>    default_outbound_access_enabled               = optional(bool, false)<br/>    nsg_key                                       = optional(string)<br/>    route_table_key                               = optional(string)<br/>    delegation = optional(object({<br/>      name            = string<br/>      service_name    = string<br/>      service_actions = optional(list(string), [])<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to all resources in the spoke Virtual Network. | `map(string)` | <pre>{<br/>  "terraformDeployed": "true"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hub_peering_id"></a> [hub\_peering\_id](#output\_hub\_peering\_id) | The resource ID of the Virtual Network Peering to the hub. |
| <a name="output_nsg_ids"></a> [nsg\_ids](#output\_nsg\_ids) | A map of NSG key to Network Security Group resource ID. |
| <a name="output_route_table_ids"></a> [route\_table\_ids](#output\_route\_table\_ids) | A map of route table key to Route Table resource ID. |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | A map of subnet key to subnet resource ID. |
| <a name="output_subnet_names"></a> [subnet\_names](#output\_subnet\_names) | A map of subnet key to subnet name. |
| <a name="output_virtual_network_id"></a> [virtual\_network\_id](#output\_virtual\_network\_id) | The resource ID of the spoke Virtual Network. |
| <a name="output_virtual_network_name"></a> [virtual\_network\_name](#output\_virtual\_network\_name) | The name of the spoke Virtual Network. |
