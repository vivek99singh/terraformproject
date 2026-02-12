output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "virtual_network_name" {
  value = module.network.virtual_network_name
}

output "subnet_name" {
  value = module.network.subnet_name
}

output "vm_id" {
  value = module.vm.vm_id
}

output "storage_account_name" {
  value = module.storage.storage_account_name
}