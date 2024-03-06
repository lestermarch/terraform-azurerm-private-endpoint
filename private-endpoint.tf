resource "azurerm_private_endpoint" "main" {
  for_each = local.endpoints_iterable

  name                = each.value.endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name

  custom_network_interface_name = each.value.network_interface_name
  subnet_id                     = var.subnet_id

  private_service_connection {
    name                           = each.value.endpoint_name
    private_connection_resource_id = each.value.resource_id
    subresource_names              = [each.value.subresource]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = each.value.subresource
    private_dns_zone_ids = each.value.private_dns_zone_ids
  }

  tags = var.resource_tags
}
