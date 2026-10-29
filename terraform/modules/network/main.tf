resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.project_name}-${var.environment}"
  address_space       = [var.environment == "prod" ? "10.20.0.0/16" : "10.10.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_subnet" "aks" {
  name                 = "snet-aks-${var.environment}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.environment == "prod" ? "10.20.0.0/22" : "10.10.1.0/24"]
}
