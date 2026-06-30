variable "resource_groups" {
  description = <<-EOT
    Resource groups to create. Each entry takes a name and location, with optional tags, managed_by,
    per-action timeouts, and a declared lock_level. The list is keyed into a map by name for a stable
    for_each.

    lock_level ("", "CanNotDelete", or "ReadOnly") is declared intent only: this module does NOT create
    the lock. A management lock is applied operationally (the terraform-azure action's lock-dance, or
    the `just azure-rg-lock` recipe) so a ReadOnly lock never races resources being deployed into the
    group. The level is surfaced on the lock_levels output for that tooling to consume.
  EOT
  type = list(object({
    name       = string
    location   = string
    tags       = optional(map(string), {})
    lock_level = optional(string, "")
    managed_by = optional(string, null)
    timeouts = optional(object({
      create = optional(string, "90m")
      read   = optional(string, "5m")
      update = optional(string, "90m")
      delete = optional(string, "90m")
    }), {})
  }))
  default = []

  validation {
    condition     = alltrue([for rg in var.resource_groups : length(trimspace(rg.name)) >= 1 && length(rg.name) <= 90])
    error_message = "Each resource_groups[*].name must be 1 to 90 characters (the Azure resource group name limit)."
  }

  validation {
    condition     = alltrue([for rg in var.resource_groups : can(regex("^[a-zA-Z0-9_().-]+$", rg.name)) && !endswith(rg.name, ".")])
    error_message = "Each resource_groups[*].name may contain only letters, digits, hyphens, underscores, parentheses, and periods, and must not end with a period."
  }

  validation {
    condition     = alltrue([for rg in var.resource_groups : contains(["", "CanNotDelete", "ReadOnly"], rg.lock_level)])
    error_message = "Each resource_groups[*].lock_level must be \"\" (none), \"CanNotDelete\", or \"ReadOnly\"."
  }
}
