output "resource_group_name" {
  value       = module.resource_group.name
  description = "The name of the resource group"
}

output "vnet_id" {
  value       = module.network.vnet_id
  description = "The ID of the virtual network"
}

output "subnet_id" {
  value       = module.network.subnet_id
  description = "The ID of the first subnet"
}

output "vm_id" {
  value       = module.vm.vm_id
  description = "The ID of the virtual machine"
}

output "public_ip_address" {
  value       = module.network.public_ip_address
  description = "The public IP address of the VM"
}