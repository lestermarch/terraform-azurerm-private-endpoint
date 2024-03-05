terraform {
  required_version = "~> 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Random string and integer for resource naming
resource "random_pet" "resource_suffix" {}

resource "random_integer" "entropy" {
  min = 100
  max = 999
}

# Temporary resources for Terraform test
resource "azurerm_resource_group" "terraform_test" {
  name     = local.resource_name.resource_group
  location = var.location
}

resource "azurerm_virtual_network" "terraform_test" {
  name                = local.resource_name.virtual_network
  location            = var.location
  resource_group_name = azurerm_resource_group.terraform_test.name

  address_space = [var.address_space]
}

resource "azurerm_subnet" "terraform_test" {
  name                = "PrivateEndpointSubnet"
  resource_group_name = azurerm_resource_group.terraform_test.name

  address_prefixes     = [var.address_space]
  virtual_network_name = azurerm_virtual_network.terraform_test.name
}

resource "azurerm_private_dns_zone" "privatelink_blob_core_windows_net" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.terraform_test.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_blob_core_windows_net" {
  name                  = azurerm_private_dns_zone.privatelink_blob_core_windows_net.name
  resource_group_name   = azurerm_resource_group.terraform_test.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_blob_core_windows_net.name
  virtual_network_id    = azurerm_virtual_network.terraform_test.id
}

resource "azurerm_private_dns_zone" "privatelink_file_core_windows_net" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.terraform_test.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_file_core_windows_net" {
  name                  = azurerm_private_dns_zone.privatelink_file_core_windows_net.name
  resource_group_name   = azurerm_resource_group.terraform_test.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_file_core_windows_net.name
  virtual_network_id    = azurerm_virtual_network.terraform_test.id
}
