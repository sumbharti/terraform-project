output "storage_account_name" {
  description = "The name of the storage account created for the compute infra"
  value       = azurerm_storage_account.main.name
}

output "access_key" {
  description = "The name of the storage account created for the compute infra"
  value       = azurerm_storage_account.main.primary_access_key
}