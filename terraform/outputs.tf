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
  description = "Primary Blob Endpoint of the storage account"
}