/*
  이 모듈은 MySQL Flexible Server와 관련된 리소스들을 생성합니다.
  - Private DNS Zone (MySQL 전용)
  - 해당 DNS Zone과 VNet을 연결하는 Virtual Network Link
  - MySQL Flexible Server
*/

resource "azurerm_private_dns_zone" "mysql_dns" {
  name                = var.dns_zone_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
  name                  = var.dns_link_name
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.mysql_dns.name
  virtual_network_id    = var.virtual_network_id
}

resource "azurerm_mysql_flexible_server" "db_manoit" {
  name                = var.mysql_server_name
  resource_group_name = var.resource_group_name
  location            = var.location
  zone                = var.zone  # 고정된 zone 값을 사용


  administrator_login    = var.mysql_admin_login
  administrator_password = var.mysql_admin_password

  version  = var.mysql_version
  sku_name = var.mysql_sku_name

  storage {
    size_gb           = var.mysql_storage_size_gb
    auto_grow_enabled = true
  }

  backup_retention_days        = var.mysql_backup_retention_days
  geo_redundant_backup_enabled = var.mysql_geo_redundant_backup_enabled

  delegated_subnet_id = var.delegated_subnet_id      
  private_dns_zone_id = azurerm_private_dns_zone.mysql_dns.id

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.dns_link
  ]
}
