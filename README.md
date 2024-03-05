# Terraform Module Template
Terraform module template with tooling configuration and devcontainer definition.

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
| [azurerm_private_endpoint.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_endpoints"></a> [endpoints](#input\_endpoints) | A list of objects used to configure one or more private endpoints for one or more resources, in the format:<pre>[<br>  {<br>    resource_id = "/subscriptions/storageAccounts/stexample"<br>    subresource = {<br>      blob = {<br>        endpoint_name          = "pe-stexample-blob"<br>        network_interface_name = "pe-nic-stexample-blob"<br>        private_dns_zone_ids   = ["/subscriptions/.../privateDnsZones/privatelink.blob.core.windows.net"]<br>      }<br>      dfs = {<br>        endpoint_name          = "pe-stexample-dfs"<br>        network_interface_name = "pe-nic-stexample-dfs"<br>        private_dns_zone_ids   = ["/subscriptions/.../privateDnsZones/privatelink.dfs.core.windows.net"]<br>      }<br>    }<br>  }<br>]</pre>Endpoint and interface names will be automatically generated if not provided. | <pre>list(object({<br>    resource_id = string<br>    subresource = map(object({<br>      endpoint_name          = optional(string)<br>      network_interface_name = optional(string)<br>      private_dns_zone_ids   = list(string)<br>    }))<br>  }))</pre> | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The primary region into which resources will be deployed. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group into which resources will be deployed. | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The ID of the virtual network subnet in which private endpoints will be provisioned. | `string` | n/a | yes |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | A map of key/value pairs to be assigned as resource tags on taggable resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoints"></a> [endpoints](#output\_endpoints) | A map of private endpoints to private dns zone records, in the format:<pre>{<br>  pe-stexample-blob = {<br>    privatelink.blob.core.windows.net = {<br>      blob = {<br>        fqdn         = "pe-stexample.privatelink.blob.core.windows.net"<br>        ip_addresses = ["10.0.0.5"]<br>      }<br>    }<br>  pe-stexample-dfs = {<br>    privatelink.dfs.core.windows.net = {<br>      dfs = {<br>        fqdn         = "pe-stexample.privatelink.dfs.core.windows.net"<br>        ip_addresses = ["10.0.0.6"]<br>      }<br>    }<br>  }<br>}</pre> |
<!-- END_TF_DOCS -->
