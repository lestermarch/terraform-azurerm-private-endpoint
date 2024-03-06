locals {
  # Flattened list of private endpoint configurations
  endpoints = flatten([
    for resource in var.endpoints : [
      for subresource, endpoint in resource.subresource : {
        endpoint_name = coalesce(
          endpoint.endpoint_name,
          join("-",
            [
              "pe",
              element(split("/", resource.resource_id), length(split("/", resource.resource_id)) - 1),
              subresource
            ]
          )
        )
        network_interface_name = coalesce(
          endpoint.network_interface_name,
          join("-",
            [
              "pe",
              "nic",
              element(split("/", resource.resource_id), length(split("/", resource.resource_id)) - 1),
              subresource
            ]
          )
        )
        private_dns_zone_ids = endpoint.private_dns_zone_ids
        resource_id          = resource.resource_id
        subresource          = subresource
      }
    ]
  ])

  # Map of private endpoint names to their configuration
  endpoints_iterable = {
    for endpoint in local.endpoints :
    endpoint.endpoint_name => endpoint
  }

  # Map of private endpoint network interface names to IDs
  network_interface_ids = var.log_analytics_workspace_id != null ? {
    for endpoint, config in azurerm_private_endpoint.main :
    config.network_interface[0].name => config.network_interface[0].id
  } : {}
}
