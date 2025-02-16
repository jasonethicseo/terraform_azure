output "mysql_server_id" {
  description = "ID of the MySQL Flexible Server"
  value       = azurerm_mysql_flexible_server.db_manoit.id
}

output "private_dns_zone_id" {
  description = "ID of the private DNS zone"
  value       = azurerm_private_dns_zone.mysql_dns.id
}

output "dns_link_id" {
  description = "ID of the DNS zone virtual network link"
  value       = azurerm_private_dns_zone_virtual_network_link.dns_link.id
}
