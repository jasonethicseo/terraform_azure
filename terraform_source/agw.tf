# resource "azurerm_public_ip" "agw_pip" {
#   name                = "pip-agw"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   allocation_method   = "Static"
#   sku                 = "Standard"
#   zones               = [1, 2, 3]
# }


# resource "azurerm_application_gateway" "agw1" {
#   name                = "agw-manoit-test"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location

#   sku {
#     name     = "Standard_v2"
#     tier     = "Standard_v2"
#     capacity = 2
#   }

#   gateway_ip_configuration {
#     name      = "gateway-ip-config"
#     subnet_id = azurerm_subnet.agwsubnet_1.id
#   }

#   frontend_port {
#     name = "http-port"
#     port = 80
#   }

#   frontend_ip_configuration {
#     name                 = "frontend-ip-config"
#     public_ip_address_id = azurerm_public_ip.agw_pip.id
#   }

#   backend_address_pool {
#     name = "bep-manoit-80"
#   }

#   backend_http_settings {
#     name                  = "backend-http-settings"
#     cookie_based_affinity = "Disabled"
#     port                  = 80
#     protocol             = "Http"
#     request_timeout      = 20
#   }

#   http_listener {
#     name                           = "http-listener"
#     frontend_ip_configuration_name = "frontend-ip-config"
#     frontend_port_name            = "http-port"
#     protocol                      = "Http"
#   }

#   request_routing_rule {
#     name                       = "route-rule"
#     rule_type                 = "Basic"
#     http_listener_name        = "http-listener"
#     backend_address_pool_name = "bep-manoit-80"
#     backend_http_settings_name = "backend-http-settings"
#     priority                  = 1
#   }

#   depends_on = [
#     azurerm_public_ip.agw_pip,
#     azurerm_subnet.agwsubnet_1
#   ]
# }

# # 백엔드 VM의 NIC를 백엔드 풀에 연결하는 연결 설정
# resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "bep-nic-vm" {
#   network_interface_id    = azurerm_network_interface.app_nic_1.id  # 백엔드 VM의 NIC ID를 지정해야 함
#   ip_configuration_name   = "internal"  # NIC의 IP 구성 이름
#   backend_address_pool_id = tolist(azurerm_application_gateway.agw1.backend_address_pool)[0].id

#   depends_on = [
#     azurerm_application_gateway.agw1
#   ]

# }
