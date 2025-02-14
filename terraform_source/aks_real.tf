# AKS 클러스터 생성
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-manoit-test"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks-manoit"
  # kubernetes_version  = "1.30.6"  # 안정적인 최신 버전 지정
  
  # 프라이빗 클러스터 설정
  private_cluster_enabled = true
  private_dns_zone_id    = "System"
  
  # AKS 네트워크 설정
  network_profile {
    network_plugin     = "azure"
    network_policy     = "azure"
    service_cidr       = "10.1.0.0/24"
    dns_service_ip     = "10.1.0.10"
  }

  # 기본 노드풀 설정
  default_node_pool {
    name                = "default"
    node_count          = 2
    vm_size             = "Standard_DS2_v2"
    vnet_subnet_id      = azurerm_subnet.natprv_2.id
    enable_auto_scaling = false
    # min_count           = 1
    # max_count           = 3

  }

  identity {
    type = "SystemAssigned"
  }

  # RBAC 설정 - 간단하게
  role_based_access_control_enabled = true

  # Azure Monitor 설정
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks_logs.id
  }

  # # 태그 설정
  # tags = {
  #   Environment = "Test"
  #   Managed_By  = "Terraform"
  # }

  depends_on = [
    azurerm_subnet.natprv_2
  ]
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "aks_logs" {
  name                = "aks-log-workspace"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  
  tags = {
    Environment = "Test"
    Managed_By  = "Terraform"
  }
}

# AKS 클러스터 데이터 소스
data "azurerm_kubernetes_cluster" "aks" {
  name                = azurerm_kubernetes_cluster.aks.name
  resource_group_name = azurerm_resource_group.rg.name
  depends_on          = [azurerm_kubernetes_cluster.aks]
}

# VNet 데이터 소스
data "azurerm_virtual_network" "vnet" {
  name                = azurerm_virtual_network.vnet.name
  resource_group_name = azurerm_resource_group.rg.name
  depends_on          = [azurerm_virtual_network.vnet]
}

# Subnet 데이터 소스
data "azurerm_subnet" "aks_subnet" {
  name                 = azurerm_subnet.natprv_2.name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
  depends_on          = [azurerm_subnet.natprv_2]
}

# 랜덤 UUID 생성
resource "random_uuid" "aks_network_role_id" {}

# AKS Managed Identity에 네트워크 권한 부여
resource "azurerm_role_assignment" "aks_network_contributor" {
  scope                = data.azurerm_virtual_network.vnet.id  # VNet 전체에 대한 권한 부여
  role_definition_name = "Network Contributor"
  principal_id         = data.azurerm_kubernetes_cluster.aks.identity[0].principal_id
  name                 = random_uuid.aks_network_role_id.result
  
  depends_on = [
    azurerm_kubernetes_cluster.aks,
    data.azurerm_kubernetes_cluster.aks
  ]
}
