data "azurerm_key_vault" "key_vault" {
  name                = "manoit-test-key2"           # Key Vault 이름
  resource_group_name = "rg-manoit-keys"            # 리소스 그룹 이름
}

data "azurerm_key_vault_secret" "ssh_public_key" {
  name         = "0206-test-key"                      # 비밀 이름
  key_vault_id = data.azurerm_key_vault.key_vault.id
}


# # 9. Compute 리소스: NAT 프라이빗 VM 예시 (AZ 1)
# resource "azurerm_linux_virtual_machine" "natprv_vm_1" {
#   name                  = "natprv-vm-1"
#   resource_group_name   = azurerm_resource_group.rg.name
#   location              = azurerm_resource_group.rg.location
#   size                  = "Standard_DS1_v2"
#   admin_username        = "azureuser"
#   network_interface_ids = [azurerm_network_interface.app_nic_1.id]
#   zone                  = "1"

#   admin_ssh_key {
#     username   = "azureuser"
#     public_key = data.azurerm_key_vault_secret.ssh_public_key.value
#   }



#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "StandardSSD_LRS"
#     disk_size_gb         = 64
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-jammy"  # 수정된 부분
#     sku       = "22_04-lts"                     # 수정된 부분
#     version   = "latest"
#   }
# }



# # 13. Compute 리소스의 NIC 생성 예시
# resource "azurerm_network_interface" "app_nic_1" {
#   name                = "app-nic-1"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name

#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = azurerm_subnet.natprv_1.id
#     private_ip_address_allocation = "Dynamic"
#   }
# }


# # NIC 전용 NSG 생성
# resource "azurerm_network_security_group" "nsg_natprv_nic" {
#   name                = "nsg-natprv-nic"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name

#   security_rule {
#     name                       = "AllowSSH"
#     priority                   = 100
#     direction                  = "Inbound"         # Outbound에서 Inbound로 변경
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range         = "*"
#     destination_port_range    = "22"
#     source_address_prefix      = "*"               # 필요한 경우 특정 IP 범위로 제한 가능
#     destination_address_prefix = "*"
#   }

#   security_rule {
#     name                       = "AllowHTTP"
#     priority                   = 101
#     direction                  = "Inbound"         # Outbound에서 Inbound로 변경
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range         = "*"
#     destination_port_range    = "80"
#     source_address_prefix      = "*"               # 필요한 경우 특정 IP 범위로 제한 가능
#     destination_address_prefix = "*"
#   }

#   security_rule {
#     name                       = "AllowHTTPS"
#     priority                   = 102
#     direction                  = "Inbound"         # Outbound에서 Inbound로 변경
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range         = "*"
#     destination_port_range    = "443"
#     source_address_prefix      = "*"               # 필요한 경우 특정 IP 범위로 제한 가능
#     destination_address_prefix = "*"
#   }


# }

# # NIC에 NSG 연결
# resource "azurerm_network_interface_security_group_association" "nic_nsg_association" {
#   network_interface_id      = azurerm_network_interface.app_nic_1.id
#   network_security_group_id = azurerm_network_security_group.nsg_natprv_nic.id
# }