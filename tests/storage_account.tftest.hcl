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

run "create_storage_account_one" {
  module {
    source = "./tests/setup/storage_account"
  }
}

run "create_storage_account_two" {
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
        resource_id = run.create_storage_account_one.storage_account_id
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
      },
      {
        resource_id  = run.create_storage_account_two.storage_account_id
        auto_approve = true
        subresource = {
          blob = {
            private_dns_zone_ids = [
              run.create_virtual_network.private_dns_zone_id.storage_account.blob
            ]
          }
        }
      }
    ]
  }
}

run "validate_private_endpoint_connections" {
  module {
    source = "./tests/validate/private_endpoint_connection"
  }

  variables {
    resource_group_name    = run.create_virtual_network.resource_group_name
    private_endpoint_names = [
      "pe-terraform-test-blob",
      "pe-terraform-test-file",
      "pe-${run.create_storage_account_two.storage_account_name}-blob"
    ]
  }

  # Validate private endpoint names
  assert {
    condition     = data.azurerm_private_endpoint_connection.validate["pe-terraform-test-blob"].name == "pe-terraform-test-blob"
    error_message = "Private endpoint name should match \"pe-terraform-test-blob\"."
  }

  assert {
    condition     = data.azurerm_private_endpoint_connection.validate["pe-terraform-test-file"].name == "pe-terraform-test-file"
    error_message = "Private endpoint name should match \"pe-terraform-test-file\"."
  }

  assert {
    condition     = data.azurerm_private_endpoint_connection.validate["pe-${run.create_storage_account_two.storage_account_name}-blob"].name == "pe-${run.create_storage_account_two.storage_account_name}-blob"
    error_message = "Private endpoint name should match \"pe-${run.create_storage_account_two.storage_account_name}-blob\"."
  }

  # Validate network interface names
  assert {
    condition     = data.azurerm_private_endpoint_connection.validate["pe-terraform-test-blob"].network_interface[0].name == "pe-nic-terraform-test-blob"
    error_message = "Private endpoint network interface name should match \"pe-nic-terraform-test-blob\"."
  }

  assert {
    condition     = data.azurerm_private_endpoint_connection.validate["pe-terraform-test-file"].network_interface[0].name == "pe-nic-terraform-test-file"
    error_message = "Private endpoint network interface name should match \"pe-nic-terraform-test-file\"."
  }

  assert {
    condition     = data.azurerm_private_endpoint_connection.validate["pe-${run.create_storage_account_two.storage_account_name}-blob"].network_interface[0].name == "pe-nic-${run.create_storage_account_two.storage_account_name}-blob"
    error_message = "Private endpoint network interface name should match \"pe-nic-${run.create_storage_account_two.storage_account_name}-blob\"."
  }

  # Validate private endpoint connection status
  assert {
    condition     = data.azurerm_private_endpoint_connection.validate["pe-terraform-test-blob"].private_service_connection[0].status == "Pending"
    error_message = "Private endpoint connection request should be \"Pending\"."
  }

  assert {
    condition     = data.azurerm_private_endpoint_connection.validate["pe-terraform-test-file"].private_service_connection[0].status == "Pending"
    error_message = "Private endpoint connection request should be \"Pending\"."
  }

  assert {
    condition     = data.azurerm_private_endpoint_connection.validate["pe-${run.create_storage_account_two.storage_account_name}-blob"].private_service_connection[0].status == "Approved"
    error_message = "Private endpoint connection request should be \"Approved\"."
  }

  # Validate private endpoint connection request response
  assert {
    condition     = data.azurerm_private_endpoint_connection.validate["pe-terraform-test-blob"].private_service_connection[0].request_response == "${run.create_virtual_network.virtual_network_name}/${run.create_virtual_network.subnet_name}"
    error_message = "Private endpoint connection request response should match \"Pending request from Terraform\"."
  }

  assert {
    condition     = data.azurerm_private_endpoint_connection.validate["pe-terraform-test-file"].private_service_connection[0].request_response == "${run.create_virtual_network.virtual_network_name}/${run.create_virtual_network.subnet_name}"
    error_message = "Private endpoint connection request response should match \"Pending request from Terraform\"."
  }

  assert {
    condition     = data.azurerm_private_endpoint_connection.validate["pe-${run.create_storage_account_two.storage_account_name}-blob"].private_service_connection[0].request_response == "Auto-Approved"
    error_message = "Private endpoint connection request response should match \"Auto-Approved\"."
  }
}
