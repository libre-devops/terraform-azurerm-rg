variable "resource_groups" {
  description = <<-EOT
    Resource groups to create. Each entry takes a name and location, optional tags, and an optional
    management lock_level ("" for none, "CanNotDelete", or "ReadOnly"). The list is keyed into a map
    by name for a stable for_each.
  EOT
  type = list(object({
    name       = string
    location   = string
    tags       = optional(map(string), {})
    lock_level = optional(string, "")
  }))
  default = []

  validation {
    condition     = alltrue([for rg in var.resource_groups : length(trimspace(rg.name)) > 0])
    error_message = "Each resource_groups[*].name must be a non-empty string."
  }

  validation {
    condition     = alltrue([for rg in var.resource_groups : contains(["", "CanNotDelete", "ReadOnly"], rg.lock_level)])
    error_message = "Each resource_groups[*].lock_level must be \"\" (none), \"CanNotDelete\", or \"ReadOnly\"."
  }
}
