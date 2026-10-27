resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "aks-devops-${var.environment}"

  sku_tier = "Free"

  default_node_pool {
    name            = "system"
    node_count      = 1
    os_disk_size_gb = 64
    os_disk_type    = "Managed"
    vm_size         = "Standard_D2s_v4"
    vnet_subnet_id  = azurerm_subnet.aks.id
    upgrade_settings {
      max_surge = "10%"
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  azure_active_directory_role_based_access_control {
    tenant_id          = "4f6d9379-ac8b-476f-80a3-67dbf739dc36"
    azure_rbac_enabled = false
  }

  depends_on = [azurerm_role_assignment.aks_network]

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    load_balancer_sku   = "standard"
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}
