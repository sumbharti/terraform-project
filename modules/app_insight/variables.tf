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