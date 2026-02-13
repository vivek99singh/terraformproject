output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "vm_id" {
  value = module.vm.vm_id
}

output "vm_name" {
  value = module.vm.vm_name
}

output "vm_public_ip_address" {
  value = module.network.public_ip_address
}