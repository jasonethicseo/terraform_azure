# resource "azurerm_public_ip" "agw_pip2" {
#   name                = "pip-agw-aks"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   allocation_method   = "Static"
#   sku                = "Standard"  # V2는 Standard SKU PIP가 필요
# }


# resource "azurerm_application_gateway" "agw_aks" {
#   name                = "agw-aks"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location

#   sku {
#     name     = "Standard_v2"
#     tier     = "Standard_v2"
#     capacity = 2
#   }

#   gateway_ip_configuration {
#     name      = "gateway-ip-config-aks"
#     subnet_id = azurerm_subnet.agwsubnet_2.id  # 내부 AGW 서브넷
#   }

#   frontend_port {
#     name = "http-port-aks"
#     port = 80
#   }

#   # 두 개의 frontend_ip_configuration이 필요합니다
#   frontend_ip_configuration {
#     name                 = "frontend-ip-config-public"  # 필수 퍼블릭 IP 설정
#     public_ip_address_id = azurerm_public_ip.agw_pip2.id
#   }


#   frontend_ip_configuration {
#     name                          = "frontend-ip-config-aks"
#     subnet_id                     = azurerm_subnet.agwsubnet_2.id
#     private_ip_address_allocation = "Static"
#     private_ip_address            = "10.0.8.100"  # 내부 AGW의 고정 IP 설정
#   }

#   backend_address_pool {
#     name         = "bep-aks-80"
#     ip_addresses = ["10.1.0.192"]  # 현재 LoadBalancer IP
#   }

  

#   backend_http_settings {
#     name                  = "backend-http-settings-aks"
#     cookie_based_affinity = "Disabled"
#     port                  = 80
#     protocol             = "Http"
#     request_timeout      = 20
#   }

#   http_listener {
#     name                           = "http-listener-aks"
#     frontend_ip_configuration_name = "frontend-ip-config-aks"
#     frontend_port_name            = "http-port-aks"
#     protocol                      = "Http"
#   }

#   request_routing_rule {
#     name                       = "route-rule-aks"
#     rule_type                 = "Basic"
#     http_listener_name        = "http-listener-aks"
#     backend_address_pool_name = "bep-aks-80"
#     backend_http_settings_name = "backend-http-settings-aks"
#     priority                  = 1
#   }

#   depends_on = [
#     azurerm_subnet.agwsubnet_1
#   ]
# }
