run "setup_virtual_network" {
  module {
    source = "./tests/setup/virtual_network"
  }

  variables {
    address_space = "10.24.0.0/24"
    location      = "uksouth"
  }
}

run "setup_storage_account" {
  module {
    source = "./tests/setup/storage_account"
  }

  variables {
    location = "uksouth"
  }
}

run "create_private_endpoints" {
  command = apply

  variables {
    location            = "uksouth"
    resource_group_name = run.setup_virtual_network.resource_group_name
    subnet_id           = run.setup_virtual_network.subnet_id
    endpoints = {
      resource_id = run.setup_storage_account.storage_account_id
      subresource = {
        blob = {
          endpoint_name          = "pe-custom-name"
          network_interface_name = "pe-nic-custom-name"
          private_dns_zone_ids = [
            run.setup_virtual_network.private_dns_zone_id.storage_account.blob
          ]
        }
        file = {
          private_dns_zone_ids = [
            run.setup_virtual_network.private_dns_zone_id.storage_account.file
          ]
        }
      }
    }
  }

  // # Validate custom endpoint name
  // assert {
  //   condition     =
  //   error_message =
  // }

  // # Validate custom network interface name
  // assert {
  //   condition     =
  //   error_message =
  // }

  // # Validate default endpoint name
  // assert {
  //   condition     =
  //   error_message =
  // }

  // # Validate default network interface name
  // assert {
  //   condition     =
  //   error_message =
  // }
}
