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

resource "azurerm_storage_account" "terraform_test" {
  name                = local.resource_name.storage_account
  location            = var.location
  resource_group_name = azurerm_resource_group.terraform_test.name

  account_kind             = "StorageV2"
  account_replication_type = "LRS"
  account_tier             = "Standard"
}
