terraform {
  required_version = "~> 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

data "azurerm_private_endpoint_connection" "validate" {
  for_each = toset(var.private_endpoint_names)

  name                = each.key
  resource_group_name = var.resource_group_name
}
