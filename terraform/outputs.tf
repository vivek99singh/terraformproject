output "vm_id" {
  value = module.vm.vm_id
}

output "vm_name" {
  value = module.vm.vm_name
}

output "network_interface_id" {
  value = module.vm.nic_id
}

output "admin_password" {
  value     = module.vm.admin_password
  sensitive = true
}