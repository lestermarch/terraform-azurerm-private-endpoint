provider "azurerm" {
  features {}
}

variables {
  location = "uksouth"
}

run "create_virtual_network" {
  module {
    source = "./tests/setup/virtual_network"
  }

  variables {
    address_space = "10.24.0.0/24"
  }
}

run "create_storage_account" {
  module {
    source = "./tests/setup/storage_account"
  }
}

run "create_private_endpoints" {
  command = apply

  variables {
    resource_group_name = run.create_virtual_network.resource_group_name
    subnet_id           = run.create_virtual_network.subnet_id
    endpoints = [
      {
        resource_id = run.create_storage_account.storage_account_id
        subresource = {
          blob = {
            endpoint_name          = "pe-terraform-test-blob"
            network_interface_name = "pe-nic-terraform-test-blob"
            private_dns_zone_ids = [
              run.create_virtual_network.private_dns_zone_id.storage_account.blob
            ]
          }
          file = {
            endpoint_name          = "pe-terraform-test-file"
            network_interface_name = "pe-nic-terraform-test-file"
            private_dns_zone_ids = [
              run.create_virtual_network.private_dns_zone_id.storage_account.file
            ]
          }
        }
      }
    ]
  }

  # Validate private endpoint names
  assert {
    condition     = azurerm_private_endpoint.main["pe-terraform-test-blob"].name == "pe-terraform-test-blob"
    error_message = "Private endpoint name should match \"pe-terraform-test-blob\"."
  }

  assert {
    condition     = azurerm_private_endpoint.main["pe-terraform-test-file"].name == "pe-terraform-test-file"
    error_message = "Private endpoint name should match \"pe-terraform-test-file\"."
  }

  # Validate network interface names
  assert {
    condition     = azurerm_private_endpoint.main["pe-terraform-test-blob"].network_interface[0].name == "pe-nic-terraform-test-blob"
    error_message = "Private endpoint network interface name should match \"pe-nic-terraform-test-blob\"."
  }

  assert {
    condition     = azurerm_private_endpoint.main["pe-terraform-test-file"].network_interface[0].name == "pe-nic-terraform-test-file"
    error_message = "Private endpoint network interface name should match \"pe-nic-terraform-test-file\"."
  }

  # Validate private DNS zone association
  assert {
    condition     = azurerm_private_endpoint.main["pe-terraform-test-blob"].private_dns_zone_configs[0].private_dns_zone_id == run.create_virtual_network.private_dns_zone_id.storage_account.blob
    error_message = "Private endpoint should be associated to the \"privatelink.blob.core.windows.net\" private DNS zone."
  }

  assert {
    condition     = azurerm_private_endpoint.main["pe-terraform-test-file"].private_dns_zone_configs[0].private_dns_zone_id == run.create_virtual_network.private_dns_zone_id.storage_account.file
    error_message = "Private endpoint should be associated to the \"privatelink.file.core.windows.net\" private DNS zone."
  }

  # Validate private endpoint FQDN
  assert {
    condition     = azurerm_private_endpoint.main["pe-terraform-test-blob"].private_dns_zone_configs[0].record_sets[0].fqdn == "${run.create_storage_account.storage_account_name}.privatelink.blob.core.windows.net"
    error_message = "Private endpoint FQDN should match \"${run.create_storage_account.storage_account_name}.blob.core.windows.net\"."
  }

  assert {
    condition     = azurerm_private_endpoint.main["pe-terraform-test-file"].private_dns_zone_configs[0].record_sets[0].fqdn == "${run.create_storage_account.storage_account_name}.privatelink.file.core.windows.net"
    error_message = "Private endpoint FQDN should match \"${run.create_storage_account.storage_account_name}.file.core.windows.net\"."
  }
}
