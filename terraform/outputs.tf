output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "vm_id" {
  value = module.vm.vm_id
}

output "vm_public_ip" {
  value = module.network.public_ip_address
}