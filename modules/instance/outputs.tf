output "vm_id" {
  description = "ID of the created virtual machine"
  value       = azurerm_linux_virtual_machine.natprv_vm.id
}

output "nic_id" {
  description = "ID of the network interface"
  value       = azurerm_network_interface.app_nic.id
}
