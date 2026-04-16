# containerAppsEnvironment

## Module Summary

Terraform module for deploying an [Azure Container Apps Environment](https://learn.microsoft.com/en-us/azure/container-apps/environment) using the `azurerm` provider (`~> 4.0`).

The Container Apps Environment is the secure boundary within which container apps run, providing shared networking, logging, and compute configuration. This module supports both serverless Consumption and dedicated workload profiles, optional VNet integration, internal load balancing, zone redundancy, and mutual TLS.

Resources deployed by this module:
- `azurerm_container_app_environment`

## How to use

### Minimal — Consumption only (default workload profile)

```hcl
module "container_apps_environment" {
  source = "../../modules/resources/containerAppsEnvironment"

  applicationPurpose = "payments"
  environment        = "prod"
  region             = "uks"
  resourceGroupName  = "rg-payments-prod-uks"
  location           = "uksouth"

  infrastructureSubnetId = azurerm_subnet.aca.id
}
```

### With Log Analytics and internal load balancer

```hcl
module "container_apps_environment" {
  source = "../../modules/resources/containerAppsEnvironment"

  applicationPurpose = "payments"
  environment        = "prod"
  region             = "uks"
  resourceGroupName  = "rg-payments-prod-uks"
  location           = "uksouth"

  infrastructureSubnetId      = azurerm_subnet.aca.id
  logAnalyticsWorkspaceId     = azurerm_log_analytics_workspace.main.id
  internalLoadBalancerEnabled = true
  zoneRedundancyEnabled       = true

  tags = {
    team = "platform"
  }
}
```

### With dedicated workload profile alongside Consumption

```hcl
module "container_apps_environment" {
  source = "../../modules/resources/containerAppsEnvironment"

  applicationPurpose = "payments"
  environment        = "prod"
  region             = "uks"
  resourceGroupName  = "rg-payments-prod-uks"
  location           = "uksouth"

  infrastructureSubnetId = azurerm_subnet.aca.id

  workloadProfiles = [
    {
      name                  = "Consumption"
      workload_profile_type = "Consumption"
      minimum_count         = 0
      maximum_count         = 0
    },
    {
      name                  = "dedicated-d4"
      workload_profile_type = "D4"
      minimum_count         = 3
      maximum_count         = 10
    }
  ]
}
```

### Workload profile validation logic

The `workloadProfiles` variable enforces two rules via input validation:

- **Consumption profiles** (`workload_profile_type = "Consumption"`) bypass instance count checks — `minimum_count` and `maximum_count` have no meaning for serverless profiles.
- **Dedicated profiles** (any other type) require `minimum_count >= 3` and `maximum_count <= 100`, and `maximum_count` must be greater than or equal to `minimum_count`.

The condition uses `||` short-circuit logic: `workload_profile_type == "Consumption" || <count checks>`. If the profile is Consumption, the right-hand side is never evaluated, so no count validation is applied.

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
| [azurerm_container_app_environment.containerAppsEnvironment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_applicationPurpose"></a> [applicationPurpose](#input\_applicationPurpose) | The purpose or workload name for this deployment, used as part of the resource naming convention (e.g. "payments", "api", "frontend"). | `string` | n/a | yes |
| <a name="input_daprApplicationInsightsConnectionString"></a> [daprApplicationInsightsConnectionString](#input\_daprApplicationInsightsConnectionString) | Application Insights connection string used for Dapr telemetry. Marked sensitive to prevent exposure in plan output. | `string` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The deployment environment, used as part of the resource naming convention (e.g. "dev", "staging", "prod"). | `string` | n/a | yes |
| <a name="input_infrastructureResourceGroupName"></a> [infrastructureResourceGroupName](#input\_infrastructureResourceGroupName) | The name of the resource group that will be created to hold the managed infrastructure resources (e.g. internal load balancer). Defaults to a platform-generated name when not set. | `string` | `null` | no |
| <a name="input_infrastructureSubnetId"></a> [infrastructureSubnetId](#input\_infrastructureSubnetId) | The ID of the subnet to use for the managed infrastructure. Must be delegated to Microsoft.App/environments. | `string` | n/a | yes |
| <a name="input_internalLoadBalancerEnabled"></a> [internalLoadBalancerEnabled](#input\_internalLoadBalancerEnabled) | When true the environment is deployed with an internal-only load balancer and public network access is disabled. Defaults to true as per organisational standards. | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the Container Apps Environment will be created. | `string` | n/a | yes |
| <a name="input_logAnalyticsWorkspaceId"></a> [logAnalyticsWorkspaceId](#input\_logAnalyticsWorkspaceId) | The ID of the Log Analytics Workspace to link to the Container Apps Environment for diagnostics. | `string` | `null` | no |
| <a name="input_mutualTlsEnabled"></a> [mutualTlsEnabled](#input\_mutualTlsEnabled) | When true, mutual TLS (mTLS) is enforced for all service-to-service communication within the environment. | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | The region abbreviation, used as part of the resource naming convention (e.g. "uks", "euw", "eus"). | `string` | n/a | yes |
| <a name="input_resourceGroupName"></a> [resourceGroupName](#input\_resourceGroupName) | The name of the resource group in which to create the Container Apps Environment. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the Container Apps Environment. | `map(string)` | <pre>{<br/>  "terraformDeployed": "true"<br/>}</pre> | no |
| <a name="input_workloadProfiles"></a> [workloadProfiles](#input\_workloadProfiles) | List of workload profile blocks to configure on the environment.<br/><br/>Each object supports:<br/>  name                  - (Required) Unique name for the workload profile.<br/>  workload\_profile\_type - (Required) The SKU type. Use "Consumption" for serverless or a<br/>                          dedicated SKU such as "D4", "D8", "D16", "D32", "E4", "E8",<br/>                          "E16", "E32", "NC24-A100", etc.<br/>  minimum\_count         - (Optional) Minimum number of instances. Not applicable to Consumption profiles.<br/>  maximum\_count         - (Optional) Maximum number of instances. Not applicable to Consumption profiles.<br/><br/>Example — mixed Consumption + dedicated profile:<br/>  workloadProfiles = [<br/>    {<br/>      name                  = "Consumption"<br/>      workload\_profile\_type = "Consumption"<br/>    },<br/>    {<br/>      name                  = "dedicated-d4"<br/>      workload\_profile\_type = "D4"<br/>      minimum\_count         = 3<br/>      maximum\_count         = 10<br/>    }<br/>  ] | <pre>list(object({<br/>    name                  = string<br/>    workload_profile_type = string<br/>    minimum_count         = optional(number)<br/>    maximum_count         = optional(number)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "maximum_count": 0,<br/>    "minimum_count": 0,<br/>    "name": "Consumption",<br/>    "workload_profile_type": "Consumption"<br/>  }<br/>]</pre> | no |
| <a name="input_zoneRedundancyEnabled"></a> [zoneRedundancyEnabled](#input\_zoneRedundancyEnabled) | When true the environment is deployed across availability zones. Defaults to true as per organisational standards — no additional cost is incurred. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_domain"></a> [default\_domain](#output\_default\_domain) | The default domain suffix of the Container Apps Environment, used to construct FQDNs for apps within it. |
| <a name="output_docker_bridge_cidr"></a> [docker\_bridge\_cidr](#output\_docker\_bridge\_cidr) | The CIDR block of the Docker bridge network used by the environment. |
| <a name="output_id"></a> [id](#output\_id) | The resource ID of the Container Apps Environment. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Container Apps Environment. |
| <a name="output_platform_reserved_cidr"></a> [platform\_reserved\_cidr](#output\_platform\_reserved\_cidr) | The IP range reserved for the Azure platform within the environment's VNet integration. |
| <a name="output_platform_reserved_dns_ip_address"></a> [platform\_reserved\_dns\_ip\_address](#output\_platform\_reserved\_dns\_ip\_address) | The DNS server IP address reserved for the Azure platform within the environment's VNet integration. |
| <a name="output_static_ip_address"></a> [static\_ip\_address](#output\_static\_ip\_address) | The static IP address associated with the Container Apps Environment. For internal environments this will be a private IP. |
<!-- END_TF_DOCS -->
