variable "project_name" {
  description = "Project name used for Azure resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "location" {
  description = "Azure resource location"
  type        = string
}

variable "resource_group_name" {
  description = "Existing Azure resource group name"
  type        = string
}
