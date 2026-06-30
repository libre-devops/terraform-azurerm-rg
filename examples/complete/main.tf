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

# Complete call: multiple resource groups, each tagged, demonstrating management locks at both
# levels. With the terraform-azure action, the lock-dance removes these for the apply and re-adds
# them after; standalone, the locks behave as normal Azure locks.
module "rg" {
  source = "../../"

  resource_groups = [
    {
      name       = "rg-${var.short}-${var.loc}-${terraform.workspace}-002"
      location   = local.location
      tags       = module.tags.tags
      lock_level = "CanNotDelete"
    },
    {
      name       = "rg-${var.short}-${var.loc}-${terraform.workspace}-003"
      location   = local.location
      tags       = module.tags.tags
      lock_level = "ReadOnly"
    },
  ]
}
