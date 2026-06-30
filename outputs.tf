output "ids" {
  description = "Map of resource group name to its id."
  value       = { for k, v in azurerm_resource_group.this : k => v.id }
}

output "locations" {
  description = "Map of resource group name to its location."
  value       = { for k, v in azurerm_resource_group.this : k => v.location }
}

output "lock_levels" {
  description = "Declared management lock level per resource group. Intent only: applied operationally by the action lock-dance or the just azure-rg-lock recipe, not by this module."
  value       = { for k, v in local.resource_group_map : k => v.lock_level }
}

output "managed_by" {
  description = "Map of resource group name to its managed_by value (null when unset)."
  value       = { for k, v in azurerm_resource_group.this : k => v.managed_by }
}

output "names" {
  description = "Map of resource group name to its name."
  value       = { for k, v in azurerm_resource_group.this : k => v.name }
}

output "resource_group_ids_zipmap" {
  description = "Map of resource group name to a { name, id } object, so the whole object can be passed where something needs the name and id together."
  value       = { for k, v in azurerm_resource_group.this : v.name => { name = v.name, id = v.id } }
}

output "resource_groups" {
  description = "The full azurerm_resource_group resources, keyed by name."
  value       = azurerm_resource_group.this
}

output "tags" {
  description = "Map of resource group name to its tags."
  value       = { for k, v in azurerm_resource_group.this : k => v.tags }
}
