output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "subnet_ids" {
  value = { for s, subnet in azurerm_subnet.subnets : s => subnet.id }
}

output "nsg_public_id" {
  value = azurerm_network_security_group.nsg_public.id
}

output "nsg_natprv_id" {
  value = azurerm_network_security_group.nsg_natprv.id
}

output "nsg_agw_id" {
  value = azurerm_network_security_group.nsg_agw.id
}

output "nsg_db_id" {
  value = azurerm_network_security_group.nsg_db.id
}

output "nat_gateway_id" {
  value = azurerm_nat_gateway.natgw.id
}

output "natgw_public_ip_id" {
  value = azurerm_public_ip.natgw_public_ip.id
}
