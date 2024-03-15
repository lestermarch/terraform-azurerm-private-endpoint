# Azure Private Endpoints

This module allows for the provisioning of multiple private endpoints for multiple Azure resources. In effect, it allows the consumer to enable private networking for their solution in a single module call, rather than having to define many `azurerm_private_endpoint` resources. If a Log Analytics Workspace is provided then network interface metrics will be enabled so as to ensure controls are met for common compliance initiatives such as ISO27001.

## Examples

1. Single resource, single endpoint, required variables:

```hcl
module {
  source  = "lestermarch/private-endpoint/azurerm"
  version = "1.0.0"

  location            = "uksouth"
  resource_group_name = "rg-example"
  subnet_id           = "/subscriptions/.../subnets/PrivateEndpointSubnet"
  endpoints = [
    {
      resource_id = "/subscriptions/.../storageAccounts/stexample"
      subresource = {
        blob = {
          private_dns_zone_ids = [
            "/subscriptions/.../privateDnsZones/privatelink.blob.core.windows.net"
          ]
        }
      }
    }
  ]
}
```

2. Auto-approve connection requests, and override endpoint and network interface names:

```hcl
module {
  source  = "lestermarch/private-endpoint/azurerm"
  version = "1.0.0"

  location            = "uksouth"
  resource_group_name = "rg-example"
  subnet_id           = "/subscriptions/.../subnets/PrivateEndpointSubnet"
  endpoints = [
    {
      resource_id  = "/subscriptions/.../storageAccounts/stexample"
      auto-approve = true
      subresource = {
        blob = {
          endpoint_name          = "stexample-blob-pe"
          network_interface_name = "stexample-blob-pe-nic"
          private_dns_zone_ids   = [
            "/subscriptions/.../privateDnsZones/privatelink.blob.core.windows.net"
          ]
        }
      }
    }
  ]
}
```

3. Multiple resources, multiple endpoints, required variables:

```hcl
module {
  source  = "lestermarch/private-endpoint/azurerm"
  version = "1.0.0"

  location            = "uksouth"
  resource_group_name = "rg-example"
  subnet_id           = "/subscriptions/.../subnets/PrivateEndpointSubnet"
  endpoints = [
    {
      # Storage account with blob and file private endpoints
      resource_id = "/subscriptions/.../storageAccounts/stexample"
      subresource = {
        blob = {
          private_dns_zone_ids = [
            "/subscriptions/.../privateDnsZones/privatelink.blob.core.windows.net"
          ]
        }
        file = {
          private_dns_zone_ids = [
            "/subscriptions/.../privateDnsZones/privatelink.file.core.windows.net"
          ]
        }
      }
    },
    {
      # Key vault with vault private endpoint
      resource_id = "/subscriptions/.../storageAccounts/kv-example"
      subresource = {
        vault = {
          private_dns_zone_ids = [
            "/subscriptions/.../privateDnsZones/privatelink.vaultcore.azure.net"
          ]
        }
      }
    }
  ]
}
```

4. Private endpoint configuration from YAML (or JSON):

```yaml
- resource_id: "/subscriptions/.../storageAccounts/stexample"
  subresource:
    blob:
      private_dns_zone_ids:
        - "/subscriptions/.../privateDnsZones/privatelink.blob.core.windows.net"
    file:
      private_dns_zone_ids:
        - "/subscriptions/.../privateDnsZones/privatelink.file.core.windows.net"

- resource_id: "/subscriptions/.../storageAccounts/kv-example"
  subresource:
    vault:
      private_dns_zone_ids:
        - "/subscriptions/.../privateDnsZones/privatelink.vaultcore.azure.net"
```

```hcl
module {
  source  = "lestermarch/private-endpoint/azurerm"
  version = "1.0.0"

  location            = "uksouth"
  resource_group_name = "rg-example"
  subnet_id           = "/subscriptions/.../subnets/PrivateEndpointSubnet"
  endpoints           = yamldecode(file("${path.module}/config/private-endpoints.yaml"))

  # For JSON:
  # endpoints = jsondecode(file("${path.module}/config/private-endpoints.json"))
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.94.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_diagnostic_setting.private_endpoint_network_interface](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_endpoints"></a> [endpoints](#input\_endpoints) | A map of objects used to configure one or more private endpoints for one or more resources, in the format:<pre>{<br>  stexample = {<br>    resource_id  = "/subscriptions/storageAccounts/stexample"<br>    auto_approve = true<br>    subresource = {<br>      blob = {<br>        endpoint_name          = "pe-stexample-blob"<br>        network_interface_name = "pe-nic-stexample-blob"<br>        private_dns_zone_ids   = ["/subscriptions/.../privateDnsZones/privatelink.blob.core.windows.net"]<br>      }<br>      dfs = {<br>        endpoint_name          = "pe-stexample-dfs"<br>        network_interface_name = "pe-nic-stexample-dfs"<br>        private_dns_zone_ids   = ["/subscriptions/.../privateDnsZones/privatelink.dfs.core.windows.net"]<br>      }<br>    }<br>  }<br>}</pre>Notes:<br>- Each endpoint object must have a unique map key and must be statically defined. It is recommended to use the resource name for this, if known.<br>- Setting `auto_approve` to `true` requires that the deployment prinicpal has the appropriate RBAC role assigned on the target `resource_id`.<br>- Endpoint and network interface names will be automatically generated unless `endpoint_name` or `network_interface_name` are specified. | <pre>map(object({<br>    resource_id  = string<br>    auto_approve = optional(bool)<br>    subresource = map(object({<br>      endpoint_name          = optional(string)<br>      network_interface_name = optional(string)<br>      private_dns_zone_ids   = list(string)<br>    }))<br>  }))</pre> | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The primary region into which resources will be deployed. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group into which resources will be deployed. | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The ID of the virtual network subnet in which private endpoints will be provisioned. | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | The ID of a log analytics workspace to forward network interface metrics to. | `string` | `null` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | A map of key/value pairs to be assigned as resource tags on taggable resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoints"></a> [endpoints](#output\_endpoints) | A map of private endpoints to private dns zone records, in the format:<pre>{<br>  pe-stexample-blob = {<br>    privatelink.blob.core.windows.net = {<br>      stexample = {<br>        blob = {<br>          fqdn         = "pe-stexample.privatelink.blob.core.windows.net"<br>          ip_addresses = ["10.0.0.5"]<br>        }<br>      }<br>    }<br>  pe-stexample-dfs = {<br>    privatelink.dfs.core.windows.net = {<br>      stexample = {<br>        dfs = {<br>          fqdn         = "pe-stexample.privatelink.dfs.core.windows.net"<br>          ip_addresses = ["10.0.0.6"]<br>        }<br>      }<br>    }<br>  }<br>}</pre> |
<!-- END_TF_DOCS -->
