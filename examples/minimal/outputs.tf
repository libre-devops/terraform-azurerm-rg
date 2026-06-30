output "ids" {
  description = "Map of resource group name to id."
  value       = module.rg.ids
}

output "names" {
  description = "Map of resource group name to name."
  value       = module.rg.names
}

output "tags" {
  description = "The tag map applied to the resource group."
  value       = module.tags.tags
}
