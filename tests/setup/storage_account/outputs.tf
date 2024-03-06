output "storage_account_id" {
  description = "The ID of the storage account."
  value       = azurerm_storage_account.terraform_test.id
}

output "storage_account_name" {
  description = "The name of the storage account."
  value       = azurerm_storage_account.terraform_test.name
}
