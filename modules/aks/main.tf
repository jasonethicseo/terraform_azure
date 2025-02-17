resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix

  private_cluster_enabled = var.private_cluster_enabled
  private_dns_zone_id     = var.private_dns_zone_id

  network_profile {
    network_plugin = var.network_plugin
    network_policy = var.network_policy
    service_cidr   = var.service_cidr
    dns_service_ip = var.dns_service_ip
  }

  default_node_pool {
    name                = var.default_node_pool_name
    node_count          = var.node_count
    vm_size             = var.vm_size
    vnet_subnet_id      = var.vnet_subnet_id
    # enable_auto_scaling = var.enable_auto_scaling
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control_enabled = var.rbac_enabled

  # oms_agent {
  #   log_analytics_workspace_id = var.log_analytics_workspace_id
  # }
}
