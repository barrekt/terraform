# subnet

## Module Summary

Terraform module for deploying an [Azure Subnet](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-manage-subnet) using the `azurerm` provider (`~> 4.0`).

Subnets are managed independently from the parent Virtual Network to keep topology composition flexible. Each subnet defaults to a secure posture: default outbound internet access is disabled, and private endpoint network policies are set to `Disabled`. Service delegation is supported for managed services such as Azure Container Apps. NSG and route table associations are optional — pass the resource IDs to wire them up inline.

Resources deployed by this module:
- `azurerm_subnet`
- `azurerm_subnet_network_security_group_association` (when `networkSecurityGroupId` is provided)
- `azurerm_subnet_route_table_association` (when `routeTableId` is provided)

## How to use

### Minimal

```hcl
module "subnet" {
  source = "../../modules/resources/subnet"

  applicationPurpose = "payments"
  environment        = "prod"
  region             = "uks"
  resourceGroupName  = "rg-payments-prod-uks"
  virtualNetworkName = module.virtual_network.name
  addressPrefixes    = ["10.0.1.0/24"]
}
```

### Delegated to Azure Container Apps

```hcl
module "subnet" {
  source = "../../modules/resources/subnet"

  applicationPurpose = "payments"
  environment        = "prod"
  region             = "uks"
  resourceGroupName  = "rg-payments-prod-uks"
  virtualNetworkName = module.virtual_network.name
  addressPrefixes    = ["10.0.1.0/24"]

  delegation = {
    name        = "aca-delegation"
    serviceName = "Microsoft.App/environments"
  }
}
```

### With NSG and route table association

```hcl
module "subnet" {
  source = "../../modules/resources/subnet"

  applicationPurpose = "payments"
  environment        = "prod"
  region             = "uks"
  resourceGroupName  = "rg-payments-prod-uks"
  virtualNetworkName = module.virtual_network.name
  addressPrefixes    = ["10.0.1.0/24"]

  networkSecurityGroupId = module.network_security_group.id
  routeTableId           = module.route_table.id
}
```

### NSG and route table association

The `networkSecurityGroupId` and `routeTableId` inputs are both optional and default to `null`. When provided, the module creates the corresponding association resource inline using `count = 1`. When omitted, no association resource is created.

Both inputs are validated against their respective Azure resource ID formats to catch misconfigured values at plan time rather than apply time.

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
| [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.nsgAssociation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_route_table_association.routeTableAssociation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addressPrefixes"></a> [addressPrefixes](#input\_addressPrefixes) | A list of CIDR blocks to assign to the subnet (e.g. ["10.0.1.0/24"]). Must fall within the parent Virtual Network address space. | `list(string)` | n/a | yes |
| <a name="input_applicationPurpose"></a> [applicationPurpose](#input\_applicationPurpose) | The purpose or workload name for this deployment, used as part of the resource naming convention (e.g. "payments", "api", "frontend"). | `string` | n/a | yes |
| <a name="input_defaultOutboundAccessEnabled"></a> [defaultOutboundAccessEnabled](#input\_defaultOutboundAccessEnabled) | When true, default outbound internet access is enabled for resources in this subnet. Defaults to false in line with Azure's recommended security posture. | `bool` | `false` | no |
| <a name="input_delegation"></a> [delegation](#input\_delegation) | Optional service delegation block for the subnet. Required when the subnet is used by a managed service such as Azure Container Apps.<br/><br/>Each object supports:<br/>  name           - (Required) A name for the delegation (e.g. "aca-delegation").<br/>  serviceName    - (Required) The service to delegate to (e.g. "Microsoft.App/environments").<br/>  serviceActions - (Optional) List of actions permitted to the delegated service. Defaults to [] which lets Azure apply the correct actions automatically.<br/><br/>Example — delegating to Azure Container Apps:<br/>  delegation = {<br/>    name        = "aca-delegation"<br/>    serviceName = "Microsoft.App/environments"<br/>  } | <pre>object({<br/>    name           = string<br/>    serviceName    = string<br/>    serviceActions = optional(list(string), [])<br/>  })</pre> | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The deployment environment, used as part of the resource naming convention (e.g. "dev", "staging", "prod"). | `string` | n/a | yes |
| <a name="input_networkSecurityGroupId"></a> [networkSecurityGroupId](#input\_networkSecurityGroupId) | The resource ID of the Network Security Group to associate with this subnet. When null, no NSG association is created. | `string` | `null` | no |
| <a name="input_privateEndpointNetworkPolicies"></a> [privateEndpointNetworkPolicies](#input\_privateEndpointNetworkPolicies) | Controls network policies on private endpoint NICs within this subnet. Valid values are "Disabled", "Enabled", "NetworkSecurityGroupEnabled", "RouteTableEnabled". | `string` | `"Disabled"` | no |
| <a name="input_privateLinkServiceNetworkPoliciesEnabled"></a> [privateLinkServiceNetworkPoliciesEnabled](#input\_privateLinkServiceNetworkPoliciesEnabled) | When true, network policies are applied to the private link service NIC in this subnet. | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | The region abbreviation, used as part of the resource naming convention (e.g. "uks", "euw", "eus"). | `string` | n/a | yes |
| <a name="input_resourceGroupName"></a> [resourceGroupName](#input\_resourceGroupName) | The name of the resource group in which the parent Virtual Network resides. | `string` | n/a | yes |
| <a name="input_routeTableId"></a> [routeTableId](#input\_routeTableId) | The resource ID of the Route Table to associate with this subnet. When null, no route table association is created. | `string` | `null` | no |
| <a name="input_serviceEndpoints"></a> [serviceEndpoints](#input\_serviceEndpoints) | A list of service endpoints to enable on the subnet (e.g. ["Microsoft.Storage", "Microsoft.KeyVault"]). | `list(string)` | `[]` | no |
| <a name="input_virtualNetworkName"></a> [virtualNetworkName](#input\_virtualNetworkName) | The name of the Virtual Network in which to create the subnet. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_addressPrefixes"></a> [addressPrefixes](#output\_addressPrefixes) | The CIDR blocks assigned to the subnet. |
| <a name="output_id"></a> [id](#output\_id) | The resource ID of the subnet. |
| <a name="output_name"></a> [name](#output\_name) | The name of the subnet. |
<!-- END_TF_DOCS -->
