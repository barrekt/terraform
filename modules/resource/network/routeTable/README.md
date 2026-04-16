# routeTable

## Module Summary

Terraform module for deploying an [Azure Route Table](https://learn.microsoft.com/en-us/azure/virtual-network/manage-route-table) and its routes using the `azurerm` provider (`~> 4.0`).

The route table and its routes are tightly coupled — individual routes cannot exist without a parent route table. Both resources are managed within this module. The route table is associated with subnets via the `subnet` module by passing `module.route_table.id` to `routeTableId`.

BGP route propagation defaults to `false`, which is the correct setting for hub-and-spoke topologies where routing is controlled explicitly through the route table rather than learned dynamically.

Resources deployed by this module:
- `azurerm_route_table`
- `azurerm_route` (one per entry in `routes`)

## How to use

### Minimal — route table with no routes

```hcl
module "route_table" {
  source = "../../modules/resources/routeTable"

  applicationPurpose = "payments"
  environment        = "prod"
  region             = "uks"
  resourceGroupName  = "rg-payments-prod-uks"
  location           = "uksouth"
}
```

### With a default route to a hub firewall

```hcl
module "route_table" {
  source = "../../modules/resources/routeTable"

  applicationPurpose = "payments"
  environment        = "prod"
  region             = "uks"
  resourceGroupName  = "rg-payments-prod-uks"
  location           = "uksouth"

  routes = [
    {
      name               = "default-to-firewall"
      addressPrefix      = "0.0.0.0/0"
      nextHopType        = "VirtualAppliance"
      nextHopInIpAddress = "10.0.0.4"
    }
  ]

  tags = {
    team = "platform"
  }
}
```

### Associating the route table with a subnet

```hcl
module "subnet" {
  source = "../../modules/resources/subnet"

  # ...
  routeTableId = module.route_table.id
}
```

### VirtualAppliance next hop requirement

When `nextHopType` is `"VirtualAppliance"`, the `nextHopInIpAddress` field is required and must contain the private IP address of the appliance (e.g. a hub firewall). For all other next hop types (`"Internet"`, `"VnetLocal"`, `"VirtualNetworkGateway"`, `"None"`), `nextHopInIpAddress` is ignored and set to `null` by the module. This is enforced at plan time by an input validation rule.

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
| [azurerm_route.route](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route) | resource |
| [azurerm_route_table.routeTable](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_applicationPurpose"></a> [applicationPurpose](#input\_applicationPurpose) | The purpose or workload name for this deployment, used as part of the resource naming convention (e.g. "payments", "api", "frontend"). | `string` | n/a | yes |
| <a name="input_bgpRoutePropagationEnabled"></a> [bgpRoutePropagationEnabled](#input\_bgpRoutePropagationEnabled) | When true, routes learned via BGP are propagated to the route table. Defaults to false to prevent unintended routing in hub-and-spoke topologies. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The deployment environment, used as part of the resource naming convention (e.g. "dev", "staging", "prod"). | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the Route Table will be created. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region abbreviation, used as part of the resource naming convention (e.g. "uks", "euw", "eus"). | `string` | n/a | yes |
| <a name="input_resourceGroupName"></a> [resourceGroupName](#input\_resourceGroupName) | The name of the resource group in which to create the Route Table. | `string` | n/a | yes |
| <a name="input_routes"></a> [routes](#input\_routes) | A list of routes to create within the Route Table.<br/><br/>Each object supports:<br/>  name                 - (Required) A unique name for the route.<br/>  addressPrefix        - (Required) The destination CIDR block this route applies to (e.g. "0.0.0.0/0").<br/>  nextHopType          - (Required) The type of next hop. Must be one of: "VirtualNetworkGateway", "VnetLocal", "Internet", "VirtualAppliance", "None".<br/>  nextHopInIpAddress   - (Optional) The IP address of the next hop. Required when nextHopType is "VirtualAppliance". | <pre>list(object({<br/>    name               = string<br/>    addressPrefix      = string<br/>    nextHopType        = string<br/>    nextHopInIpAddress = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the Route Table. | `map(string)` | <pre>{<br/>  "terraformDeployed": "true"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The resource ID of the Route Table. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Route Table. |
<!-- END_TF_DOCS -->
