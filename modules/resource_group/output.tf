output "resource_group_name" {
  description = "The name of the resource group created for the compute infra"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "The location of the storage account"
  value = azurerm_resource_group.main.location
}