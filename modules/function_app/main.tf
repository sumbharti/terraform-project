locals {
  resource_group_name = var.resource_group_name
  resource_group_location = var.location
  storage_account_name = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key
  appinsight_connection_string = var.appinsight_connection_string
  appinsight_instrumentation_key = var.appinsight_instrumentation_key
  common_tags = merge(var.tags, {
    owner: "devops-team"
  })
}

# Create function app

resource "azurerm_service_plan" "main" {
  name                = "sb2-${local.resource_group_location}-${terraform.workspace}-asp-01"
  resource_group_name = local.resource_group_name
  location            = local.resource_group_location
  os_type             = "Windows"
  sku_name            = "B1"

  tags = var.tags
}

resource "azurerm_windows_function_app" "main" {
  name = "sb2-${local.resource_group_location}-${terraform.workspace}-fa-01"
  location = local.resource_group_location
  resource_group_name = local.resource_group_name
  service_plan_id = azurerm_service_plan.main.id

  storage_account_name = local.storage_account_name
  storage_account_access_key = local.storage_account_access_key

  site_config {
    application_insights_connection_string = local.appinsight_connection_string
    application_insights_key = local.appinsight_instrumentation_key
    application_stack {
      dotnet_version = "v10.0"
      use_dotnet_isolated_runtime = true
    }

    cors {
      allowed_origins = [
        "https://portal.azure.com"
      ]

      support_credentials = false
    }
  }

  app_settings = {
    FUNCTIONS_EXTENSION_VERSION           = "~4"
    FUNCTIONS_WORKER_RUNTIME              = "dotnet-isolated"
    APPLICATIONINSIGHTS_CONNECTION_STRING = local.appinsight_connection_string
    APPINSIGHTS_INSTRUMENTATIONKEY        = local.appinsight_instrumentation_key
  }

  depends_on = [ azurerm_service_plan.main ]

  tags = var.tags
}

resource "azurerm_function_app_function" "main" {
  name = "default1"
  language = "CSharp"
  function_app_id = azurerm_windows_function_app.main.id
  config_json = jsonencode({
    "bindings" = [
      {
        "authLevel" = "function"
        "direction" = "in"
        "methods" = [
          "get",
          "post",
        ]
        "name" = "req"
        "type" = "httpTrigger"
      },
      {
        "direction" = "out"
        "name"      = "$return"
        "type"      = "http"
      },
    ]
  })

  depends_on = [ azurerm_windows_function_app.main ]
}