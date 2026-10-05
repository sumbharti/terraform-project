variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "centralindia"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "sb2-terraform-example"
}

variable "storage_account_name" {
  description = "The name of storage account"
  type        = string
  default     = "sb2ciexamplestorage01"
}

