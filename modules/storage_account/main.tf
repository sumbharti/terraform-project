locals {
  resource_group_name = var.resource_group_name
  resource_group_location = var.location
  common_tags = merge(var.tags, {
    owner: "devops-team"
  })
}

# Create a storage account
resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  resource_group_name      = local.resource_group_name
  location                 = local.resource_group_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  tags = local.common_tags
}