# Plan-time tests for the module. The azurerm provider is mocked, so no credentials, no
# features block, and no cloud calls are needed:
#   terraform init -backend=false && terraform test

mock_provider "azurerm" {}

variables {
  resource_groups = [
    {
      name     = "rg-ldo-uks-tst-rg"
      location = "uksouth"
    },
  ]
}

run "creates_the_resource_group" {
  command = plan

  assert {
    condition     = azurerm_resource_group.this["rg-ldo-uks-tst-rg"].location == "uksouth"
    error_message = "The resource group should be created in the requested location."
  }

  assert {
    condition     = length(azurerm_resource_group.this) == length(var.resource_groups)
    error_message = "One resource group should be created per list entry."
  }

  assert {
    condition     = output.resource_group_ids_zipmap["rg-ldo-uks-tst-rg"].name == "rg-ldo-uks-tst-rg"
    error_message = "resource_group_ids_zipmap should map each name to a { name, id } object."
  }
}

run "timeouts_default_to_azurerm_defaults" {
  command = plan

  assert {
    condition     = azurerm_resource_group.this["rg-ldo-uks-tst-rg"].timeouts.create == "90m" && azurerm_resource_group.this["rg-ldo-uks-tst-rg"].timeouts.read == "5m" && azurerm_resource_group.this["rg-ldo-uks-tst-rg"].timeouts.delete == "90m"
    error_message = "Timeouts should default to the azurerm defaults (create/update/delete 90m, read 5m)."
  }
}

run "timeouts_can_be_overridden" {
  command = plan

  variables {
    resource_groups = [
      {
        name     = "rg-ldo-uks-tst-rg"
        location = "uksouth"
        timeouts = { create = "30m" }
      },
    ]
  }

  assert {
    condition     = azurerm_resource_group.this["rg-ldo-uks-tst-rg"].timeouts.create == "30m"
    error_message = "An overridden create timeout should be used."
  }

  assert {
    condition     = azurerm_resource_group.this["rg-ldo-uks-tst-rg"].timeouts.delete == "90m"
    error_message = "Timeouts not overridden should keep their default."
  }
}

run "managed_by_passthrough" {
  command = plan

  variables {
    resource_groups = [
      {
        name       = "rg-ldo-uks-tst-rg"
        location   = "uksouth"
        managed_by = "/subscriptions/0000/resourceGroups/mgmt/providers/Microsoft.Foo/bars/baz"
      },
    ]
  }

  assert {
    condition     = azurerm_resource_group.this["rg-ldo-uks-tst-rg"].managed_by == "/subscriptions/0000/resourceGroups/mgmt/providers/Microsoft.Foo/bars/baz"
    error_message = "managed_by should be passed through to the resource group."
  }
}

run "lock_level_is_declared_intent_only" {
  command = plan

  variables {
    resource_groups = [
      {
        name       = "rg-ldo-uks-tst-rg"
        location   = "uksouth"
        lock_level = "ReadOnly"
      },
    ]
  }

  assert {
    condition     = output.lock_levels["rg-ldo-uks-tst-rg"] == "ReadOnly"
    error_message = "The declared lock_level should be surfaced on the lock_levels output for the operational lock-dance."
  }
}

run "rejects_an_invalid_lock_level" {
  command = plan

  variables {
    resource_groups = [
      {
        name       = "rg-ldo-uks-tst-bad"
        location   = "uksouth"
        lock_level = "Frozen"
      },
    ]
  }

  expect_failures = [var.resource_groups]
}

run "rejects_a_name_over_90_characters" {
  command = plan

  variables {
    resource_groups = [
      {
        name     = "rg-${join("", [for i in range(95) : "x"])}"
        location = "uksouth"
      },
    ]
  }

  expect_failures = [var.resource_groups]
}

run "rejects_invalid_name_characters" {
  command = plan

  variables {
    resource_groups = [
      {
        name     = "rg ldo uks tst bad!"
        location = "uksouth"
      },
    ]
  }

  expect_failures = [var.resource_groups]
}
