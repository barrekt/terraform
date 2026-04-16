# virtualNetwork

## Module Summary

Terraform module for deploying an [Azure Virtual Network](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview) using the `azurerm` provider (`~> 4.0`).

A Virtual Network is the fundamental private networking boundary in Azure. This module provisions the VNet itself — subnets are managed separately via the `subnet` module, keeping network topology composition flexible. DDoS protection is intentionally omitted; in a hub-and-spoke architecture, traffic is centralised through a shared firewall which handles perimeter security.

Resources deployed by this module:
- `azurerm_virtual_network`

## How to use

### Minimal

```hcl
module "virtual_network" {
  source = "../../modules/resources/virtualNetwork"

  applicationPurpose = "payments"
  environment        = "prod"
  region             = "uks"
  resourceGroupName  = "rg-payments-prod-uks"
  location           = "uksouth"
  addressSpace       = ["10.0.0.0/16"]
}
```

### With custom DNS servers

```hcl
module "virtual_network" {
  source = "../../modules/resources/virtualNetwork"

  applicationPurpose = "payments"
  environment        = "prod"
  region             = "uks"
  resourceGroupName  = "rg-payments-prod-uks"
  location           = "uksouth"
  addressSpace       = ["10.0.0.0/16"]

  dnsServers = ["10.0.0.4", "10.0.0.5"]

  tags = {
    team = "platform"
  }
}
```

### Passing outputs to a subnet module

```hcl
module "virtual_network" {
  source = "../../modules/resources/virtualNetwork"

  applicationPurpose = "payments"
  environment        = "prod"
  region             = "uks"
  resourceGroupName  = "rg-payments-prod-uks"
  location           = "uksouth"
  addressSpace       = ["10.0.0.0/16"]
}

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
| [azurerm_virtual_network.virtualNetwork](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addressSpace"></a> [addressSpace](#input\_addressSpace) | A list of CIDR blocks that define the address space of the Virtual Network (e.g. ["10.0.0.0/16"]). | `list(string)` | n/a | yes |
| <a name="input_applicationPurpose"></a> [applicationPurpose](#input\_applicationPurpose) | The purpose or workload name for this deployment, used as part of the resource naming convention (e.g. "payments", "api", "frontend"). | `string` | n/a | yes |
| <a name="input_dnsServers"></a> [dnsServers](#input\_dnsServers) | A list of custom DNS server IP addresses for the Virtual Network. When empty, Azure-provided DNS is used. | `list(string)` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The deployment environment, used as part of the resource naming convention (e.g. "dev", "staging", "prod"). | `string` | n/a | yes |
| <a name="input_flowTimeoutInMinutes"></a> [flowTimeoutInMinutes](#input\_flowTimeoutInMinutes) | The flow timeout in minutes for the Virtual Network. Must be between 4 and 30. When null, the Azure default applies. | `number` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the Virtual Network will be created. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region abbreviation, used as part of the resource naming convention (e.g. "uks", "euw", "eus"). | `string` | n/a | yes |
| <a name="input_resourceGroupName"></a> [resourceGroupName](#input\_resourceGroupName) | The name of the resource group in which to create the Virtual Network. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the Virtual Network. | `map(string)` | <pre>{<br/>  "terraformDeployed": "true"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_guid"></a> [guid](#output\_guid) | The GUID of the Virtual Network. |
| <a name="output_id"></a> [id](#output\_id) | The resource ID of the Virtual Network. |
| <a name="output_location"></a> [location](#output\_location) | The Azure region where the Virtual Network is deployed. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Virtual Network. |
<!-- END_TF_DOCS -->
