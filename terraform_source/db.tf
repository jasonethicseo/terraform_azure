
# Private DNS Zone 생성
resource "azurerm_private_dns_zone" "mysql_dns" {
  name                = "db-manoit.private.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

# Private DNS Zone과 VNet 연결
resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
  name                  = "mysql-vnet-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.mysql_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}


############################
# MySQL Flexible Server
############################
resource "azurerm_mysql_flexible_server" "db_manoit" {
  name                = "db-manoit"
  resource_group_name = "rg-manoit-test"
  location            = "Korea Central"

  administrator_login    = "jasonseo"
  administrator_password = "Digital123!"

  version = "8.0.21"
  sku_name = "B_Standard_B1ms"

  storage {
    size_gb           = 20
    auto_grow_enabled = true
  }

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

#   public_network_access_enabled = false

  delegated_subnet_id = azurerm_subnet.dbsubnet_1.id      
  private_dns_zone_id = azurerm_private_dns_zone.mysql_dns.id


  depends_on = [azurerm_virtual_network.vnet,
  azurerm_subnet.dbsubnet_1]


}

