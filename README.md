# Introduction to Terraform


# Terraform Azure Registry


# Variables and Workspace


# State Management, Locking and Versioning

Follow the steps below and create Storage account to manage terraform state files, enable versioning and locking.

### create a resource group for the state storage
az group create --location centralindia --resource-group rg-terraform-state

### create a storage account with a unique storage name 
az storage account create --name <YOUR_UNIQUE_STORAGE_ACCOUNT_NAME> --resource-group rg-terraform-state --sku Standard_LRS --encryption-services blob --location centralindia

### create a container for the state file. use a unique account name
az storage container create --name tfstate --account-name <YOUR_UNIQUE_STORAGE_ACCOUNT_NAME>

### enable versioning for state file history.
az storage account blob-service-properties update --resource-group rg-terraform-state --account-name <YOUR_UNIQUE_STORAGE_ACCOUNT_NAME> --enable-versioning true

### enable blob soft delete & container soft delete
az storage account blob-service-properties update --resource-group rg-terraform-state --account-name <YOUR_UNIQUE_STORAGE_ACCOUNT_NAME> --enable-delete-retention true --delete-retention-days 14 --enable-container-delete-retention true --container-delete-retention-days 9


## Steps to recover from a corrupted Terraform state file to stable version

### download a copy of the remote state file 
terraform state pull | jq '.' > state_debug.json

### get the list of versions of your state file. 
az storage blob list --container-name tfstate --account-name <YOUR_UNIQUE_STORAGE_ACCOUNT_NAME>  --query "[?name=='terraform.tfstate'].{Version:versionId,LastModified:properties.lastModified,Size:properties.contentLength,IsCurrentVersion:isCurrentVersion}" --include v --output table

### download from azure blob
az storage blob download --container-name tfstate --account-name <YOUR_UNIQUE_STORAGE_ACCOUNT_NAME> --version-id "<VERSION-ID>" --file restore_state.json --name terraform.tfstate

### upload the recovered state, 
az storage blob upload --container-name tfstate --account-name <YOUR_UNIQUE_STORAGE_ACCOUNT_NAME> --file restore_state.json --name terraform.tfstate --overwrite

