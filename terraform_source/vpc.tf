# Terraform 버전 및 제공자 설정
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.64.0, < 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# 1. 리소스 그룹 생성
resource "azurerm_resource_group" "rg" {
  name     = "rg-manoit-test"
  location = "Korea Central"  # 원하는 지역으로 변경하세요
}

# 2. 가상 네트워크(VNet) 생성
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-manoit-test"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# 3. 서브넷 생성
# 3.1 퍼블릭 서브넷 1
resource "azurerm_subnet" "public_1" {
  name                 = "pub-subnet-1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# 3.2 퍼블릭 서브넷 2
resource "azurerm_subnet" "public_2" {
  name                 = "pub-subnet-2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# 3.3 NAT 프라이빗 서브넷 1
resource "azurerm_subnet" "natprv_1" {
  name                 = "natprv-subnet-1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

# 3.4 NAT 프라이빗 서브넷 2
resource "azurerm_subnet" "natprv_2" {
  name                 = "natprv-subnet-2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.4.0/24"]
}

# 3.5 데이터베이스 서브넷 1
resource "azurerm_subnet" "dbsubnet_1" {
  name                 = "db-subnet-1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.5.0/24"]

  delegation {
    name = "dbsubnet_delegation"
    service_delegation {
      name    = "Microsoft.DBforMySQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }

}


# 3.6 데이터베이스 서브넷 2
resource "azurerm_subnet" "dbsubnet_2" {
  name                 = "db-subnet-2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.6.0/24"]
}

resource "azurerm_subnet" "agwsubnet_1" {
  name                 = "agw-subnet-1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.7.0/24"]
}


resource "azurerm_subnet" "agwsubnet_2" {
  name                 = "agw-subnet-2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.8.0/24"]
}


# 4. 네트워크 보안 그룹(NSG) 생성
# 4.1 퍼블릭 서브넷 NSG (모든 인바운드 트래픽 허용)
resource "azurerm_network_security_group" "nsg_public" {
  name                = "nsg-public"
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

# 4.2 NAT 프라이빗 서브넷 NSG (포트 22만 허용)
resource "azurerm_network_security_group" "nsg_natprv" {
  name                = "nsg-natprv"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # ssh(22번) 허용
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


  # HTTP(80번) 허용
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

  # HTTPS(443번) 허용
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

  # security_rule {
  #   name                       = "Allowingress"
  #   priority                   = 130
  #   direction                  = "Inbound"
  #   access                     = "Allow"
  #   protocol                   = "Tcp"
  #   source_port_range          = "*"
  #   destination_port_range     = "10254"
  #   source_address_prefix      = "*"
  #   destination_address_prefix = "*"
  # }


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


  # kubelet 포트 허용
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


resource "azurerm_network_security_group" "nsg_agw" {
  name                = "nsg-agw"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name


  # HTTP(80번) 허용
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

  # HTTPS(443번) 허용
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



# 4.3 데이터베이스 서브넷 NSG (모든 인바운드 트래픽 차단)
resource "azurerm_network_security_group" "nsg_db" {
  name                = "nsg-db"
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

# 5. 서브넷에 NSG 연결
resource "azurerm_subnet_network_security_group_association" "assoc_public_1" {
  subnet_id                 = azurerm_subnet.public_1.id
  network_security_group_id = azurerm_network_security_group.nsg_public.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_public_2" {
  subnet_id                 = azurerm_subnet.public_2.id
  network_security_group_id = azurerm_network_security_group.nsg_public.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_natprv_1" {
  subnet_id                 = azurerm_subnet.natprv_1.id
  network_security_group_id = azurerm_network_security_group.nsg_natprv.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_natprv_2" {
  subnet_id                 = azurerm_subnet.natprv_2.id
  network_security_group_id = azurerm_network_security_group.nsg_natprv.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_dbsubnet_1" {
  subnet_id                 = azurerm_subnet.dbsubnet_1.id
  network_security_group_id = azurerm_network_security_group.nsg_db.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_dbsubnet_2" {
  subnet_id                 = azurerm_subnet.dbsubnet_2.id
  network_security_group_id = azurerm_network_security_group.nsg_db.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_agwsubnet_1" {
  subnet_id                 = azurerm_subnet.agwsubnet_1.id
  network_security_group_id = azurerm_network_security_group.nsg_agw.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_agwsubnet_2" {
  subnet_id                 = azurerm_subnet.agwsubnet_2.id
  network_security_group_id = azurerm_network_security_group.nsg_agw.id
}




# 6. NAT 게이트웨이 생성 및 연결
# 6.1 퍼블릭 IP 생성 (NAT 게이트웨이용)
resource "azurerm_public_ip" "natprv_1_pip" {
  name                = "pip-natprv-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# resource "azurerm_public_ip" "natprv_2_pip" {
#   name                = "pip-natprv-2"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   allocation_method   = "Static"
#   sku                 = "Standard"
# }




# 6.2 NAT 게이트웨이 생성
# 6.2 NAT 게이트웨이 생성
resource "azurerm_nat_gateway" "natprv_1" {
  name                = "natgw-natprv-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Standard"
  idle_timeout_in_minutes = 5
}

# resource "azurerm_nat_gateway" "natprv_2" {
#   name                = "natgw-natprv-2"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   sku_name            = "Standard"
#   idle_timeout_in_minutes = 5
# }

# NAT Gateway와 Public IP 연결
resource "azurerm_nat_gateway_public_ip_association" "natprv_1" {
  nat_gateway_id       = azurerm_nat_gateway.natprv_1.id
  public_ip_address_id = azurerm_public_ip.natprv_1_pip.id
}

# resource "azurerm_nat_gateway_public_ip_association" "natprv_2" {
#   nat_gateway_id       = azurerm_nat_gateway.natprv_2.id
#   public_ip_address_id = azurerm_public_ip.natprv_2_pip.id
# }


# NAT 게이트웨이와 NAT 프라이빗 서브넷 연결
resource "azurerm_subnet_nat_gateway_association" "assoc_natprv_1" {
  subnet_id      = azurerm_subnet.natprv_1.id
  nat_gateway_id = azurerm_nat_gateway.natprv_1.id
}

resource "azurerm_subnet_nat_gateway_association" "assoc_natprv_2" {
  subnet_id      = azurerm_subnet.natprv_2.id
  nat_gateway_id = azurerm_nat_gateway.natprv_1.id
}
