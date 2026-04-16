# virtualNetworkPeering

## Module Summary

Terraform module for deploying an [Azure Virtual Network Peering](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview) link using the `azurerm` provider (`~> 4.0`).

A single instance of this module creates **one directional peering link**. For bidirectional peering, call the module twice — once for each direction. The remote VNet is referenced by its full resource ID, which supports cross-subscription peering without any assumptions about the remote VNet's naming convention or subscription context.

Resources deployed by this module:
- `azurerm_virtual_network_peering`

## How to use

### Bidirectional peering between a spoke and hub (same subscription)

```hcl
module "peer_spoke_to_hub" {
  source = "../../modules/resources/virtualNetworkPeering"

  applicationPurpose     = "spoke-to-hub"
  environment            = "prod"
  region                 = "uks"
  resourceGroupName      = "rg-payments-prod-uks"
  virtualNetworkName     = module.spoke_vnet.name
  remoteVirtualNetworkId = module.hub_vnet.id

  allowForwardedTraffic = true
  useRemoteGateways     = false
}

module "peer_hub_to_spoke" {
  source = "../../modules/resources/virtualNetworkPeering"

  applicationPurpose     = "hub-to-spoke"
  environment            = "prod"
  region                 = "uks"
  resourceGroupName      = "rg-hub-prod-uks"
  virtualNetworkName     = module.hub_vnet.name
  remoteVirtualNetworkId = module.spoke_vnet.id

  allowForwardedTraffic = true
  allowGatewayTransit   = false
}
```

### Cross-subscription peering

```hcl
module "peer_spoke_to_hub" {
  source = "../../modules/resources/virtualNetworkPeering"

  applicationPurpose     = "spoke-to-hub"
  environment            = "prod"
  region                 = "uks"
  resourceGroupName      = "rg-payments-prod-uks"
  virtualNetworkName     = module.spoke_vnet.name
  remoteVirtualNetworkId = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-prod-uks/providers/Microsoft.Network/virtualNetworks/vnet-hub-prod-uks"

  allowForwardedTraffic = true
}
```

### Bidirectional peering and directional settings

VNet peering in Azure is **not symmetric** — each direction is an independent resource with its own settings. This module represents one link. To establish full bidirectional connectivity, two module instances must be created: one from A→B and one from B→A.

The three peering behaviour flags have different defaults depending on which side of the peering they apply to:

| Variable | Spoke side | Hub side | Purpose |
|---|---|---|---|
| `allowForwardedTraffic` | `true` | `true` | Allows traffic that didn't originate in the local VNet (e.g. from behind a firewall) |
| `allowGatewayTransit` | `false` | `true` (when hub has a gateway) | Lets the hub share its VPN/ExpressRoute gateway with spokes |
| `useRemoteGateways` | `true` (when hub has a gateway) | `false` | Makes the spoke use the hub's gateway for on-premises routing |

If `allowGatewayTransit` and `useRemoteGateways` are not in use in your topology, the defaults (`allowForwardedTraffic = true`, both gateway flags `false`) are suitable for a standard hub-and-spoke with a firewall as the central routing appliance.

## Terraform Docs

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_virtual_network_peering.virtualNetworkPeering](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowForwardedTraffic"></a> [allowForwardedTraffic](#input\_allowForwardedTraffic) | When true, forwarded traffic originating outside the local Virtual Network is allowed through this peering. Required when routing through a hub firewall. | `bool` | `true` | no |
| <a name="input_allowGatewayTransit"></a> [allowGatewayTransit](#input\_allowGatewayTransit) | When true, the local Virtual Network can use its gateway to provide transit to the remote Virtual Network. Typically enabled on the hub side of a hub-and-spoke topology. | `bool` | `false` | no |
| <a name="input_allowVirtualNetworkAccess"></a> [allowVirtualNetworkAccess](#input\_allowVirtualNetworkAccess) | When true, resources in the remote Virtual Network can access resources in the local Virtual Network. | `bool` | `true` | no |
| <a name="input_applicationPurpose"></a> [applicationPurpose](#input\_applicationPurpose) | The purpose or workload name for this deployment, used as part of the resource naming convention (e.g. "payments", "api", "frontend"). | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The deployment environment, used as part of the resource naming convention (e.g. "dev", "staging", "prod"). | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region abbreviation, used as part of the resource naming convention (e.g. "uks", "euw", "eus"). | `string` | n/a | yes |
| <a name="input_remoteVirtualNetworkId"></a> [remoteVirtualNetworkId](#input\_remoteVirtualNetworkId) | The full resource ID of the remote Virtual Network to peer with. Supports cross-subscription peering. | `string` | n/a | yes |
| <a name="input_resourceGroupName"></a> [resourceGroupName](#input\_resourceGroupName) | The name of the resource group containing the local Virtual Network. | `string` | n/a | yes |
| <a name="input_useRemoteGateways"></a> [useRemoteGateways](#input\_useRemoteGateways) | When true, traffic from the local Virtual Network uses the gateway in the remote Virtual Network. Requires the remote VNet to have allowGatewayTransit enabled. Typically enabled on spoke side. | `bool` | `false` | no |
| <a name="input_virtualNetworkName"></a> [virtualNetworkName](#input\_virtualNetworkName) | The name of the local Virtual Network from which this peering link originates. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The resource ID of the Virtual Network Peering. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Virtual Network Peering. |
<!-- END_TF_DOCS -->
