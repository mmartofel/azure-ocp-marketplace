output "bastion_public_ip" {
  value = azurerm_public_ip.bastion_public_ip.ip_address
}

output "bastion_hostname" {
  value = azurerm_linux_virtual_machine.bastion_vm.computer_name
}