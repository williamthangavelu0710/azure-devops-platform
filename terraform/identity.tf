resource "azurerm_user_assigned_identity" "aks" {
  name                = "id-aks-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_role_assignment" "aks_network" {
  scope                = azurerm_subnet.aks.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = var.environment == "prod" ? data.azurerm_container_registry.shared[0].id : azurerm_container_registry.main[0].id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}

resource "azurerm_role_assignment" "prod_cluster_user" {
  count                = var.environment == "prod" ? 1 : 0
  scope                = azurerm_kubernetes_cluster.main.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = var.prod_deployer_principal_id
}

resource "azurerm_role_assignment" "prod_namespace_writer" {
  count                = var.environment == "prod" ? 1 : 0
  scope                = "${azurerm_kubernetes_cluster.main.id}/namespaces/prod"
  role_definition_name = "Azure Kubernetes Service RBAC Writer"
  principal_id         = var.prod_deployer_principal_id
}
