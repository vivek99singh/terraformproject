output "subnet_id" {
  value       = module.network.subnet_id
  description = "ID of the first subnet"
}

output "public_ip_id" {
  value       = module.network.public_ip_id
  description = "Public IP ID"
}

output "vm_id" {
  value       = module.vm.vm_id
  description = "ID of the virtual machine"
}

output "vm_name" {
  value       = module.vm.vm_name
  description = "Name of the virtual machine"
}

output "admin_password" {
  value       = module.vm.admin_password
  description = "Admin password for the VM"
  sensitive   = true
}