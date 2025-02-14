# Public IP (필요하다면)
resource "azurerm_public_ip" "openvpn_public_ip" {
  name                = "pip-openvpn"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# OpenVPN 전용 NIC 생성
resource "azurerm_network_interface" "openvpn_nic" {
  name                = "openvpn-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "openvpn-nic-config"
    subnet_id                     = azurerm_subnet.public_1.id  # 퍼블릭 서브넷에 연결
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.openvpn_public_ip.id
  }
}

# OpenVPN용 NSG 생성 (필요 포트 허용)
resource "azurerm_network_security_group" "nsg_openvpn" {
  name                = "nsg-openvpn"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # OpenVPN Web UI (443/TCP)
  security_rule {
    name                       = "AllowOpenVPNUI443"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # OpenVPN Admin UI (943/TCP)
  security_rule {
    name                       = "AllowOpenVPNAdmin943"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "943"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # OpenVPN 터널(1194/UDP)
  security_rule {
    name                       = "AllowOpenVPNTunnel1194"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "1194"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # SSH (22/TCP) - 필요시 열기
  security_rule {
    name                       = "AllowSSH"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Outbound는 전체 허용 (필요시 수정)
  security_rule {
    name                       = "AllowAllOutbound"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# NIC에 NSG 연결
resource "azurerm_network_interface_security_group_association" "openvpn_nic_assoc" {
  network_interface_id      = azurerm_network_interface.openvpn_nic.id
  network_security_group_id = azurerm_network_security_group.nsg_openvpn.id
}

# OpenVPN Access Server Marketplace 약관 동의
resource "azurerm_marketplace_agreement" "openvpn" {
  publisher = "openvpn"
  offer     = "openvpnas"
  plan      = "byol"
}


resource "azurerm_linux_virtual_machine" "openvpn_vm" {
  name                  = "openvpn-test"  # VM 이름 변경
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_B1s"  # 사이즈 변경
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.openvpn_nic.id]

  zone = "1"  # 가용성 영역 추가

  source_image_reference {
    publisher = "openvpn"
    offer     = "openvpnas"
    sku       = "openvpnas"  # sku 변경 (byol -> openvpnas)
    version   = "latest"
  }

  plan {
    name      = "openvpnas"  # plan 변경 (byol -> openvpnas)
    product   = "openvpnas"
    publisher = "openvpn"
  }

  admin_ssh_key {
    username   = "azureuser"
    public_key = data.azurerm_key_vault_secret.ssh_public_key.value
  }



  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"  # 디스크 타입 변경
  }
}



##############
# OpenVPN Access Server VM 생성
# resource "azurerm_linux_virtual_machine" "openvpn_vm" {
#   name                  = "openvpn-vm"
#   resource_group_name   = azurerm_resource_group.rg.name
#   location              = azurerm_resource_group.rg.location
#   size                  = "Standard_DS1_v2"
#   admin_username        = "azureuser"
#   network_interface_ids = [azurerm_network_interface.openvpn_nic.id]

#   source_image_reference {
#     publisher = "openvpn"
#     offer     = "openvpnas"
#     sku       = "byol"
#     version   = "latest"
#   }

#   plan {
#     name      = "byol"
#     product   = "openvpnas"
#     publisher = "openvpn"
#   }

#   admin_ssh_key {
#     username   = "azureuser"
#     public_key = file("~/.ssh/jason-test.pub")
#   }

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "StandardSSD_LRS"
#     disk_size_gb         = 64
#   }
# }