output "ids" {
  description = "Map of resource group name to id."
  value       = module.rg.ids
}

output "lock_ids" {
  description = "Map of resource group name to its management lock id."
  value       = module.rg.lock_ids
}

output "names" {
  description = "Map of resource group name to name."
  value       = module.rg.names
}

output "tags" {
  description = "The tag map applied to the resource groups."
  value       = module.tags.tags
}
