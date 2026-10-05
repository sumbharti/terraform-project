locals {
  resource_group_name = var.resource_group_name
  resource_group_location = var.location
  common_tags = merge(var.tags, {
    owner: "devops-team"
  })
}

# Create Application insight with Log Analytics workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "sb2-${local.resource_group_location}-${terraform.workspace}-la-01"
  resource_group_name = local.resource_group_name
  location            = local.resource_group_location

  tags = local.common_tags
}

resource "azurerm_application_insights" "main" {
  name                = "sb2-${local.resource_group_location}-${terraform.workspace}-ains-01"
  resource_group_name = local.resource_group_name
  location            = local.resource_group_location
  workspace_id = azurerm_log_analytics_workspace.main.id
  application_type    = "web"

  tags = local.common_tags
}