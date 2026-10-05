# configure azure providers
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=5.0.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sb2azstoragecitfstate01"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}


# Create Resource group with module
module "rg01" {
  source = "./modules/resource_group"

  location            = var.location
  resource_group_name = var.resource_group_name
}

# Create storage account with module
module "storage01" {
  source = "./modules/storage_account"

  storage_account_name = var.storage_account_name
  resource_group_name  = module.rg01.resource_group_name
  location             = module.rg01.resource_group_location

  depends_on = [module.rg01]
}

# Create app insight with module
module "appins01" {
  source = "./modules/app_insight"

  resource_group_name = module.rg01.resource_group_name
  location            = module.rg01.resource_group_location

  depends_on = [module.rg01]
}

# Create function app with module
module "fnapp01" {
  source = "./modules/function_app"

  location = module.rg01.resource_group_location

  resource_group_name            = module.rg01.resource_group_name
  storage_account_name           = module.storage01.storage_account_name
  storage_account_access_key     = module.storage01.access_key
  appinsight_connection_string   = module.appins01.connection_string
  appinsight_instrumentation_key = module.appins01.instrumentation_key

  depends_on = [module.rg01, module.storage01, module.appins01]
}