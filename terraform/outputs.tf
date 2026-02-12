output "subnet_id" {
  value = module.network.subnet_id
}

output "nsg_id" {
  value = module.network.nsg_id
}

output "public_ip_address" {
  value = module.network.public_ip_address
}

output "vm_id" {
  value = module.vm.vm_id
}

output "vm_name" {
  value = module.vm.vm_name
}

output "nic_id" {
  value = module.vm.nic_id
}

output "admin_password" {
  value     = module.vm.admin_password
  sensitive = true
}