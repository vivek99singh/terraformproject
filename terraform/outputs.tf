output "subnet_id" {
  value       = module.network.subnet_id
  description = "ID of the first subnet"
}

output "public_ip_id" {
  value       = module.network.public_ip_id
  description = "ID of the public IP"
}

output "vm_id" {
  value       = module.vm.vm_id
  description = "ID of the virtual machine"
}