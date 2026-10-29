moved {
  from = azurerm_container_registry.main
  to   = azurerm_container_registry.main[0]
}

resource "azurerm_container_registry" "main" {
  count               = var.environment == "prod" ? 0 : 1
  name                = "acrdevopswt20261027"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = false

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

data "azurerm_container_registry" "shared" {
  count               = var.environment == "prod" ? 1 : 0
  name                = "acrdevopswt20261027"
  resource_group_name = "rg-azure-devops-platform-dev"
}
