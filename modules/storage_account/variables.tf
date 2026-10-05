variable "tags" {
  description = "The default tags for project"
  type = map(string)
  default = {
    environment = "dev"
    project = "terraform-example"
  }
}

variable "storage_account_name" {
  description = "The name of storage account"
  type = string
}

variable "location" {
    description = "The Azure region where resources will be created"
    type        = string
}

variable "resource_group_name" {
    description     = "The name of the resource group"
    type            = string
}