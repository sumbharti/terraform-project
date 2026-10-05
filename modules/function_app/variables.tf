variable "tags" {
  description = "The default tags for project"
  type = map(string)
  default = {
    environment = "dev"
    project = "terraform-example"
  }
}

variable "location" {
    description = "The Azure region where resources will be created"
    type        = string
}

variable "resource_group_name" {
    description     = "The name of the resource group"
    type            = string
}

variable "storage_account_name" {
    description     = "The name of the underlying storage account"
    type            = string
}

variable "storage_account_access_key" {
    description     = "The storage account primary key"
    type            = string
    sensitive = true
}

variable "appinsight_connection_string" {
    description     = "The underlying app insight connection string"
    type            = string
    sensitive = true
}

variable "appinsight_instrumentation_key" {
    description     = "The underlying app insight instrumentation key"
    type            = string
    sensitive = true
}