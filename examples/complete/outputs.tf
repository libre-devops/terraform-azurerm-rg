output "ids" {
  description = "Map of resource group name to id."
  value       = module.rg.ids
}

output "lock_levels" {
  description = "Declared management lock level per resource group (applied operationally, not by the module)."
  value       = module.rg.lock_levels
}

output "names" {
  description = "Map of resource group name to name."
  value       = module.rg.names
}

output "tags" {
  description = "The tag map applied to the resource groups."
  value       = module.tags.tags
}
