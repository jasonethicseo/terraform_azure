resource "azurerm_container_registry" "acr" {
  name                     = "acrmanoittest2"  // 전역 고유 이름이어야 합니다. 필요시 이름을 변경하세요.
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  sku                      = "Standard"       // 필요에 따라 Basic 또는 Premium으로 변경 가능
  admin_enabled            = false            // 보안상 admin 계정 비활성화 권장
}

# AKS에서 ACR 이미지를 Pull 할 수 있도록 권한 부여 (AKS에 Managed Identity가 있음을 전제)
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id

  depends_on = [
    azurerm_container_registry.acr,
    azurerm_kubernetes_cluster.aks
  ]
}