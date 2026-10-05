# Terraform Azure Project

This repository contains a Terraform configuration that provisions a basic Azure infrastructure stack for a sample application. It uses reusable modules for the core Azure resources and stores the Terraform state in an Azure Storage account backend.

## Architecture overview

The project deploys the following resources in Azure:

- Resource Group
- Storage Account
- Log Analytics Workspace
- Application Insights
- Azure Function App hosted on a Windows App Service plan
- An HTTP-triggered Azure Function

The root configuration wires these resources together through modules and passes values between them.

## Repository structure

```text
.
├── main.tf
├── variables.tf
├── .gitignore
├── .terraform.lock.hcl
├── modules/
│   ├── app_insight/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── output.tf
│   ├── function_app/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── output.tf
│   ├── resource_group/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── output.tf
│   └── storage_account/
│       ├── main.tf
│       ├── variables.tf
│       └── output.tf
└── README.md
```

## Root configuration

The root `main.tf` configures:

- the AzureRM Terraform provider (`hashicorp/azurerm` version `=5.0.0`)
- an Azure Storage backend for remote state management
- the resource group module
- the storage account module
- the Application Insights module
- the Function App module

The backend is configured as:

```hcl
backend "azurerm" {
  resource_group_name  = "rg-terraform-state"
  storage_account_name = "sb2azstoragecitfstate01"
  container_name       = "tfstate"
  key                  = "terraform.tfstate"
}
```

This means the Terraform state is stored in Azure Blob Storage, which is a common pattern for team-based Terraform workflows and supports remote locking/versioning.

## Variables

The project defines the following root variables in `variables.tf`:

```hcl
variable "location" {
  default = "centralindia"
}

variable "resource_group_name" {
  default = "sb2-terraform-example"
}

variable "storage_account_name" {
  default = "sb2ciexamplestorage01"
}
```

These values can be overridden in a `.tfvars` file or by setting environment-specific values for different workspaces.

## Modules

### 1. Resource Group module

Path: `modules/resource_group`

Creates an Azure resource group using:

```hcl
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}
```

### 2. Storage Account module

Path: `modules/storage_account`

Creates a standard Azure Storage Account for application usage and output values such as the account name and access key.

### 3. Application Insights module

Path: `modules/app_insight`

Creates:

- Log Analytics Workspace
- Application Insights resource

The workspace is linked to the Application Insights instance and includes default tags and a workspace-based monitoring configuration.

### 4. Function App module

Path: `modules/function_app`

Creates:

- Azure Service Plan (`Windows` / `B1`)
- Azure Windows Function App
- an HTTP-triggered function named `default1`

The Function App is configured with:

- storage account access via connection key
- Application Insights connection string and instrumentation key
- .NET isolated worker runtime
- HTTP trigger binding

## Prerequisites

Before running this project, make sure you have:

- Azure subscription access
- Azure CLI installed and authenticated (`az login`)
- Terraform installed locally
- access to create resources in the chosen Azure region

## Quick start

1. Authenticate to Azure:

```bash
az login
az account set --subscription "<your-subscription-id-or-name>"
```

2. Initialize Terraform:

```bash
terraform init
```

3. Create or select a workspace:

```bash
terraform workspace new dev
# or
terraform workspace select dev
```

4. Review the plan:

```bash
terraform plan
```

5. Apply the configuration:

```bash
terraform apply
```

6. Destroy the environment when no longer needed:

```bash
terraform destroy
```

## Remote state management in Azure

The project is designed to use Azure Blob Storage for Terraform state. The following commands show how to create the backend storage infrastructure for state management, versioning, and locking.

### Create a resource group for state storage

```bash
az group create --location centralindia --resource-group rg-terraform-state
```

### Create a storage account

```bash
az storage account create \
  --name <YOUR_UNIQUE_STORAGE_ACCOUNT_NAME> \
  --resource-group rg-terraform-state \
  --sku Standard_LRS \
  --encryption-services blob \
  --location centralindia
```

### Create the container for state files

```bash
az storage container create \
  --name tfstate \
  --account-name <YOUR_UNIQUE_STORAGE_ACCOUNT_NAME>
```

### Enable versioning for Terraform state history

```bash
az storage account blob-service-properties update \
  --resource-group rg-terraform-state \
  --account-name <YOUR_UNIQUE_STORAGE_ACCOUNT_NAME> \
  --enable-versioning true
```

### Enable blob soft delete and container soft delete

```bash
az storage account blob-service-properties update \
  --resource-group rg-terraform-state \
  --account-name <YOUR_UNIQUE_STORAGE_ACCOUNT_NAME> \
  --enable-delete-retention true \
  --delete-retention-days 14 \
  --enable-container-delete-retention true \
  --container-delete-retention-days 14
```

## Recovery from a corrupted Terraform state file

The repository includes the common state-recovery workflow used with Azure remote state storage.

### Pull the current remote state and save a local copy

```bash
terraform state pull | jq '.' > state_debug.json
```

### List available state versions

```bash
az storage blob list \
  --container-name tfstate \
  --account-name <YOUR_UNIQUE_STORAGE_ACCOUNT_NAME> \
  --query "[?name=='terraform.tfstate'].{Version:versionId,LastModified:properties.lastModified,Size:properties.contentLength}"
```

### Download a previous version

```bash
az storage blob download \
  --container-name tfstate \
  --account-name <YOUR_UNIQUE_STORAGE_ACCOUNT_NAME> \
  --version-id "<VERSION-ID>" \
  --file restore_state.json \
  --name terraform.tfstate
```

### Upload the recovered state back to Azure Storage

```bash
az storage blob upload \
  --container-name tfstate \
  --account-name <YOUR_UNIQUE_STORAGE_ACCOUNT_NAME> \
  --file restore_state.json \
  --name terraform.tfstate \
  --overwrite
```

## Notes

- This sample project demonstrates infrastructure-as-code best practices using modular Terraform.
- Naming conventions and resource values are intentionally simple and suited to a learning or demo environment.
- The configuration is structured to be extended for production workloads with stricter naming, security, networking, and monitoring controls.

## Summary

This repository provides a practical example of deploying Azure resources with Terraform using modules and Azure remote state. It is a good starting point for learning Terraform automation, Azure resource provisioning, and state management practices.
