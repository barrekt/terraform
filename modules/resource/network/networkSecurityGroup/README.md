# networkSecurityGroup

## Module Summary

Terraform module for deploying an [Azure Network Security Group](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview) and its security rules using the `azurerm` provider (`~> 4.0`).

The NSG and its rules are tightly coupled — security rules cannot exist without a parent NSG. Both resources are managed within this module. The NSG is associated with subnets via the `subnet` module by passing `module.network_security_group.id` to `networkSecurityGroupId`.

Resources deployed by this module:
- `azurerm_network_security_group`
- `azurerm_network_security_rule` (one per entry in `securityRules`)

## How to use

### Minimal — NSG with no rules

```hcl
module "network_security_group" {
  source = "../../modules/resources/networkSecurityGroup"

  applicationPurpose = "payments"
  environment        = "prod"
  region             = "uks"
  resourceGroupName  = "rg-payments-prod-uks"
  location           = "uksouth"
}
```

### With inbound and outbound rules

```hcl
module "network_security_group" {
  source = "../../modules/resources/networkSecurityGroup"

  applicationPurpose = "payments"
  environment        = "prod"
  region             = "uks"
  resourceGroupName  = "rg-payments-prod-uks"
  location           = "uksouth"

  securityRules = [
    {
      name                       = "allow-https-inbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      sourcePortRanges           = ["*"]
      sourceAddressPrefixes      = ["10.0.0.0/8"]
      destinationPortRanges      = ["443"]
      destinationAddressPrefixes = ["*"]
    },
    {
      name                       = "deny-all-inbound"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      sourcePortRanges           = ["*"]
      sourceAddressPrefixes      = ["*"]
      destinationPortRanges      = ["*"]
      destinationAddressPrefixes = ["*"]
    }
  ]

  tags = {
    team = "platform"
  }
}
```

### Associating the NSG with a subnet

```hcl
module "subnet" {
  source = "../../modules/resources/subnet"

  # ...
  networkSecurityGroupId = module.network_security_group.id
}
```

### Port range singular/plural logic

The `azurerm_network_security_rule` resource uses separate attributes for single and multiple values:

- `source_port_range` (string) — used when the value is `"*"` (all ports)
- `source_port_ranges` (list) — used for specific port ranges

This module handles the switching automatically. When `sourcePortRanges = ["*"]`, the wildcard is passed to the singular attribute and the plural attribute is set to `null`. For any other list, the plural attribute is used. The same logic applies to `destinationPortRanges`, `sourceAddressPrefixes`, and `destinationAddressPrefixes`.

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
| [azurerm_network_security_group.networkSecurityGroup](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.securityRule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_applicationPurpose"></a> [applicationPurpose](#input\_applicationPurpose) | The purpose or workload name for this deployment, used as part of the resource naming convention (e.g. "payments", "api", "frontend"). | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The deployment environment, used as part of the resource naming convention (e.g. "dev", "staging", "prod"). | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the Network Security Group will be created. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region abbreviation, used as part of the resource naming convention (e.g. "uks", "euw", "eus"). | `string` | n/a | yes |
| <a name="input_resourceGroupName"></a> [resourceGroupName](#input\_resourceGroupName) | The name of the resource group in which to create the Network Security Group. | `string` | n/a | yes |
| <a name="input_securityRules"></a> [securityRules](#input\_securityRules) | A list of security rules to create within the Network Security Group.<br/><br/>Each object supports:<br/>  name                       - (Required) A unique name for the rule.<br/>  priority                   - (Required) The priority of the rule. Must be between 100 and 4096.<br/>  direction                  - (Required) The direction of traffic. Must be "Inbound" or "Outbound".<br/>  access                     - (Required) Whether traffic is allowed or denied. Must be "Allow" or "Deny".<br/>  protocol                   - (Required) The network protocol. Must be "Tcp", "Udp", "Icmp", "Esp", "Ah", or "*".<br/>  sourcePortRanges           - (Required) List of source port ranges. Use ["*"] for all ports.<br/>  sourceAddressPrefixes      - (Required) List of source address prefixes or service tags.<br/>  destinationPortRanges      - (Required) List of destination port ranges. Use ["*"] for all ports.<br/>  destinationAddressPrefixes - (Required) List of destination address prefixes or service tags. | <pre>list(object({<br/>    name                       = string<br/>    priority                   = number<br/>    direction                  = string<br/>    access                     = string<br/>    protocol                   = string<br/>    sourcePortRanges           = list(string)<br/>    sourceAddressPrefixes      = list(string)<br/>    destinationPortRanges      = list(string)<br/>    destinationAddressPrefixes = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the Network Security Group. | `map(string)` | <pre>{<br/>  "terraformDeployed": "true"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The resource ID of the Network Security Group. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Network Security Group. |
<!-- END_TF_DOCS -->
