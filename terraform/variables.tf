variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  sensitive   = true
}

variable "location" {
  description = "Azure region for infrastructure"
  type        = string
  default     = "eastus"
}

variable "project_name" {
  description = "Project name used for Azure resource naming"
  type        = string
  default     = "azure-devops-platform"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}
