locals {
  common_tags = merge(var.tags, {
    owner: "devops-team"
  })
}

# Create a resource group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = local.common_tags
}