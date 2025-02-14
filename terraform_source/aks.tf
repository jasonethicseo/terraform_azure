# resource "azurerm_kubernetes_cluster" "aks" {
#   name                = "aks-manoit-test"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   dns_prefix          = "aks-manoit"

#   # AKS 네트워크 설정
#   private_cluster_enabled = true  # 프라이빗 클러스터 활성화 (공용 API 서버 X)
#   network_profile {
#     network_plugin = "azure"  # Azure CNI 사용
#     network_policy = "azure"
#     service_cidr   = "10.1.0.0/24"  # 서비스 CIDR
#     dns_service_ip = "10.1.0.10"     # Kubernetes 내부 DNS IP
#   }

#   default_node_pool {
#     name                = "default"
#     node_count          = 2
#     vm_size             = "Standard_DS2_v2"
#     vnet_subnet_id      = azurerm_subnet.natprv_2.id
#     enable_auto_scaling = false
#     # min_count           = 1
#     # max_count           = 3
#   }

#   identity {
#     type = "SystemAssigned"
#   }

#   # AKS 모니터링 활성화 (Container Insights)
#   oms_agent {
#     log_analytics_workspace_id = azurerm_log_analytics_workspace.aks_logs.id
#   }

#   depends_on = [
#     azurerm_subnet.natprv_2
#   ]
# }

# # Azure Monitor를 위한 Log Analytics Workspace
# resource "azurerm_log_analytics_workspace" "aks_logs" {
#   name                = "aks-log-workspace"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   sku                 = "PerGB2018"
#   retention_in_days   = 30
# }

# ############### vnet iam에 네트워크 참여자 추가하기

# # AKS 클러스터 데이터 가져오기
# data "azurerm_kubernetes_cluster" "aks" {
#   name                = "aks-manoit-test"
#   resource_group_name = "rg-manoit-test"
#   depends_on          = [azurerm_kubernetes_cluster.aks]
# }

# # VNet 및 Subnet 데이터 가져오기
# data "azurerm_virtual_network" "vnet" {
#   name                = "vnet-manoit-test"
#   resource_group_name = "rg-manoit-test"
#   depends_on          = [azurerm_virtual_network.vnet]
# }

# data "azurerm_subnet" "aks_subnet" {
#   name                 = "natprv-subnet-2"
#   virtual_network_name = data.azurerm_virtual_network.vnet.name
#   resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
#   depends_on          = [azurerm_subnet.natprv_2]  # virtual_network 대신 실제 서브넷 리소스 참조
# }

# # 랜덤 UUID 생성 (Role Assignment name을 위해)
# resource "random_uuid" "aks_network_role_id" {}

# # AKS Managed Identity에 네트워크 권한 부여
# resource "azurerm_role_assignment" "aks_network_contributor" {
#   scope                = data.azurerm_virtual_network.vnet.id
#   role_definition_name = "Network Contributor"
#   principal_id         = data.azurerm_kubernetes_cluster.aks.identity[0].principal_id
#   name                 = random_uuid.aks_network_role_id.result
#   depends_on = [
#     azurerm_kubernetes_cluster.aks,
#     data.azurerm_kubernetes_cluster.aks
#   ]
# }
