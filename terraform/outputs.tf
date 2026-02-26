output "resource_group_name" {
  value       = module.resource_group.name
  description = "The name of the resource group"
}

output "vm_id" {
  value       = module.vm.vm_id
  description = "ID of the virtual machine"
}

output "public_ip_address" {
  value       = module.vm.public_ip_address
  description = "Public IP address of the virtual machine"
}

output "subnet_ids" {
  value       = module.network.subnet_ids
  description = "IDs of all subnets"
}

output "storage_account_uri" {
  value       = module.storage.primary_blob_endpoint
  description = "Primary blob endpoint of the storage account"
}