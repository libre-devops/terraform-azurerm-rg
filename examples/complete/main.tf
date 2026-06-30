locals {
  location = lookup(var.regions, var.loc, "uksouth")
}

# Tags first, with the full surface, then the resource groups that consume them.
module "tags" {
  source  = "libre-devops/tags/azurerm"
  version = "~> 4.0"

  environment  = "prd"
  cost_centre  = "1888/67"
  owner        = "platform@example.com"
  hidden_title = "ldo-rg-complete"

  deployed_branch = var.deployed_branch
  deployed_repo   = var.deployed_repo

  additional_tags = {
    Application = "terraform-azurerm-rg"
    ManagedBy   = "Terraform"
  }
}

# Complete call: multiple resource groups exercising the full surface, tags, declared lock levels,
# managed_by, and overridden timeouts. The lock_level is declared intent only (this module does not
# create the lock); it is applied operationally by the terraform-azure action's lock-dance or the
# `just azure-rg-lock` recipe.
module "rg" {
  source = "../../"

  resource_groups = [
    {
      name       = "rg-${var.short}-${var.loc}-${terraform.workspace}-002"
      location   = local.location
      tags       = module.tags.tags
      lock_level = "CanNotDelete"
      managed_by = "terraform-azurerm-rg"
      timeouts   = { create = "60m" }
    },
    {
      name       = "rg-${var.short}-${var.loc}-${terraform.workspace}-003"
      location   = local.location
      tags       = module.tags.tags
      lock_level = "ReadOnly"
    },
  ]
}
