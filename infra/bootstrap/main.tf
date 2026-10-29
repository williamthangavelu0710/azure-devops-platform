terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id     = var.subscription_id
  storage_use_azuread = true
}

resource "azurerm_resource_group" "shared" {
  name     = "rg-azure-devops-platform-shared"
  location = "eastus"

  tags = {
    Project     = "azure-devops-platform"
    Environment = "shared"
    ManagedBy   = "Terraform"
  }
}
