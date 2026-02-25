output "resource_group_name" {
  value       = module.resource_group.name
  description = "The name of the resource group"
}

output "network_vnet_id" {
  value       = module.network.vnet_id
  description = "The ID of the virtual network"
}

output "vm_id" {
  value       = module.vm.vm_id
  description = "ID of the virtual machine"
}

output "public_ip_address" {
  value       = module.network.public_ip_address
  description = "Public IP address of the VM"
}

output "storage_account_uri" {
  value       = module.storage.primary_blob_endpoint
  description = "Primary blob endpoint of the storage account"
}