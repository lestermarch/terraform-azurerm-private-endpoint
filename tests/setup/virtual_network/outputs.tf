output "private_dns_zone_id" {
  description = "An object mapping private DNS zones to IDs."
  value = {
    storage_account = {
      blob = azurerm_private_dns_zone.privatelink_blob_core_windows_net.id
      file = azurerm_private_dns_zone.privatelink_file_core_windows_net.id
    }
  }
}

output "resource_group_name" {
  description = "The name of the resource group."
  value       = azurerm_resource_group.terraform_test.name
}

output "subnet_id" {
  description = "The ID of the private endpoint subnet."
  value       = azurerm_subnet.terraform_test.id
}

output "subnet_name" {
  description = "The name of the private endpoint subnet."
  value       = azurerm_subnet.terraform_test.name
}

output "virtual_network_name" {
  description = "The name of the virtual network."
  value       = azurerm_virtual_network.terraform_test.name
}
