resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = var.vnet_address_space
}

resource "azurerm_subnet" "subnets" {
  for_each              = var.subnets
  name                  = each.key
  resource_group_name   = azurerm_resource_group.rg.name
  virtual_network_name  = azurerm_virtual_network.vnet.name
  address_prefixes      = each.value.address_prefixes

  dynamic "delegation" {
    for_each = each.key == "dbsubnet_1" ? [1] : []
    content {
      name = "dbsubnet_delegation"
      service_delegation {
        name    = "Microsoft.DBforMySQL/flexibleServers"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
  }

}


// 퍼블릭 서브넷 NSG
resource "azurerm_network_security_group" "nsg_public" {
  name                = var.nsg_public_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowAllInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAllOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

// NAT 프라이빗 서브넷 NSG
resource "azurerm_network_security_group" "nsg_natprv" {
  name                = var.nsg_natprv_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowHTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow-nodeport"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["30000-35000"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Allow inbound traffic on kube nodeport"
  }
  security_rule {
    name                       = "Allowkubelet"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "10250"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowAllOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

// 애플리케이션 게이트웨이 NSG
resource "azurerm_network_security_group" "nsg_agw" {
  name                = var.nsg_agw_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow-AGW-HighPorts"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["65200-65535"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Allow inbound traffic on high ports required by AGW v2 SKU"
  }
  security_rule {
    name                       = "AllowAllOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

// 데이터베이스 NSG (DB)
resource "azurerm_network_security_group" "nsg_db" {
  name                = var.nsg_db_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow3306Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowAllOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
 
###############################
# NSG와 서브넷 연결
###############################

resource "azurerm_subnet_network_security_group_association" "assoc_public_1" {
  subnet_id                 = azurerm_subnet.subnets["public_1"].id
  network_security_group_id = azurerm_network_security_group.nsg_public.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_public_2" {
  subnet_id                 = azurerm_subnet.subnets["public_2"].id
  network_security_group_id = azurerm_network_security_group.nsg_public.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_natprv_1" {
  subnet_id                 = azurerm_subnet.subnets["natprv_1"].id
  network_security_group_id = azurerm_network_security_group.nsg_natprv.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_natprv_2" {
  subnet_id                 = azurerm_subnet.subnets["natprv_2"].id
  network_security_group_id = azurerm_network_security_group.nsg_natprv.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_dbsubnet_1" {
  subnet_id                 = azurerm_subnet.subnets["dbsubnet_1"].id
  network_security_group_id = azurerm_network_security_group.nsg_db.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_dbsubnet_2" {
  subnet_id                 = azurerm_subnet.subnets["dbsubnet_2"].id
  network_security_group_id = azurerm_network_security_group.nsg_db.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_agwsubnet_1" {
  subnet_id                 = azurerm_subnet.subnets["agwsubnet_1"].id
  network_security_group_id = azurerm_network_security_group.nsg_agw.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_agwsubnet_2" {
  subnet_id                 = azurerm_subnet.subnets["agwsubnet_2"].id
  network_security_group_id = azurerm_network_security_group.nsg_agw.id
}


/* NAT Gateway용 Public IP */
resource "azurerm_public_ip" "natgw_public_ip" {
  name                = var.natgw_public_ip_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = var.natgw_public_ip_sku
}

/* NAT Gateway 생성 */
resource "azurerm_nat_gateway" "natgw" {
  name                   = var.nat_gateway_name
  location               = azurerm_resource_group.rg.location
  resource_group_name    = azurerm_resource_group.rg.name
  sku_name               = var.nat_gateway_sku
  idle_timeout_in_minutes = var.nat_gateway_idle_timeout
}

/* NAT Gateway와 Public IP 연결 */
resource "azurerm_nat_gateway_public_ip_association" "natgw_association" {
  nat_gateway_id       = azurerm_nat_gateway.natgw.id
  public_ip_address_id = azurerm_public_ip.natgw_public_ip.id
}

/* NAT Gateway와 NAT 프라이빗 서브넷 연결 (natprv_1과 natprv_2에 한정) */
resource "azurerm_subnet_nat_gateway_association" "natgw_assoc" {
  for_each = { for key, subnet in azurerm_subnet.subnets : key => subnet if key == "natprv_1" || key == "natprv_2" }
  subnet_id      = each.value.id
  nat_gateway_id = azurerm_nat_gateway.natgw.id
}