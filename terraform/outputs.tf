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
  description = "The ID of the virtual machine"
}

output "storage_account_uri" {
  value       = module.storage.primary_blob_endpoint
  description = "The URI of the storage account for boot diagnostics"
}