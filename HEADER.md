<!--
  Keep the title and badges OUTSIDE the centered <div>: the Terraform Registry's markdown renderer
  does not parse markdown inside an HTML block, so a # heading or [![badge]] in the div renders as
  literal text on the registry. Only the logo (HTML) goes in the div.
-->
<div align="center">
  <a href="https://libredevops.org">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://libredevops.org/assets/libre-devops-white.png">
      <img alt="Libre DevOps" src="https://libredevops.org/assets/libre-devops-black.png" width="300">
    </picture>
  </a>
</div>

# Terraform Azure Resource Group

Creates one or more Azure resource groups from a `list(object)`, each with optional tags and an
optional management lock.

[![CI](https://github.com/libre-devops/terraform-azurerm-rg/actions/workflows/ci.yml/badge.svg)](https://github.com/libre-devops/terraform-azurerm-rg/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/libre-devops/terraform-azurerm-rg?sort=semver&label=release)](https://github.com/libre-devops/terraform-azurerm-rg/releases/latest)
[![Terraform Registry](https://img.shields.io/badge/registry-libre--devops-7B42BC?logo=terraform&logoColor=white)](https://registry.terraform.io/namespaces/libre-devops)
[![License](https://img.shields.io/github/license/libre-devops/terraform-azurerm-rg)](./LICENSE)

---

## Overview

A `for_each` over a `list(object)` so one call can create many resource groups, each with its own
tags, optional `managed_by`, and overridable per-action `timeouts` (defaulting to the azurerm defaults:
create/update/delete 90m, read 5m).

### Management locks are operational, not a module resource

`lock_level` (`""`, `CanNotDelete`, or `ReadOnly`) is **declared intent only**, surfaced on the
`lock_levels` output. This module does **not** create an `azurerm_management_lock`, on purpose: a
`ReadOnly` lock blocks all writes, and a lock resource here could only `depends_on` the resource group,
so it would be a sibling of anything you deploy into that group and would race it. Locking is therefore
applied **operationally**, after the resources exist and removed before any change, exactly like the
storage firewall dance:

- the `libre-devops/terraform-azure` action's lock-dance (opt in with
  `remove-resource-group-locks-before-tf-run`, off by default), or
- the `just azure-rg-lock <rg> <level>` / `just azure-remove-lock <rg>` recipes for manual use.

## Usage

```hcl
module "tags" {
  source  = "libre-devops/tags/azurerm"
  version = "~> 4.0"

  cost_centre = "1888/67"
  owner       = "platform@example.com"
}

module "rg" {
  source  = "libre-devops/rg/azurerm"
  version = "~> 4.0"

  resource_groups = [
    {
      name       = "rg-ldo-uks-prd-001"
      location   = "uksouth"
      tags       = module.tags.tags
      lock_level = "CanNotDelete" # declared intent; applied operationally, not by this module
    },
  ]
}
```

## Examples

- [`examples/minimal`](./examples/minimal) - one resource group, defaults only.
- [`examples/complete`](./examples/complete) - multiple resource groups exercising tags, declared lock
  levels, `managed_by`, and overridden timeouts.

Both examples call the tags module first, then this module, so they advertise both together.

## Developing

Local work needs **PowerShell 7+** and **[`just`](https://github.com/casey/just)**, because the
recipes wrap the [LibreDevOpsHelpers](https://www.powershellgallery.com/packages/LibreDevOpsHelpers)
PowerShell module (the same engine the `libre-devops/terraform-azure` action runs in CI). Install
just with `brew install just`, or `uv tool add rust-just` then `uv run just <recipe>`.

Run `just` to list recipes: `just update-ldo-pwsh` (install or force-update LibreDevOpsHelpers from
PSGallery), `just validate`, `just scan` (Trivy only), `just pwsh-analyze` (PSScriptAnalyzer only),
`just plan`, `just apply`, `just destroy`, `just e2e`, `just test`, and `just docs` (the
plan/apply/destroy recipes mirror the action, including the storage firewall dance; `just e2e`
applies an example then always destroys it, defaulting to `minimal`, so nothing is left running).
Releasing is also `just`:
`just increment-release [patch|minor|major]` bumps, tags, and publishes a GitHub release, and the
Terraform Registry picks up the tag.

## Security scan exceptions

This module is scanned with [Trivy](https://github.com/aquasecurity/trivy); HIGH and CRITICAL
findings fail the build. Any waiver is a deliberate, reviewed decision, never a way to quiet a
finding that should be fixed. Waivers live in [`.trivyignore.yaml`](./.trivyignore.yaml) (the
machine-applied source of truth, passed to Trivy with `--ignorefile`) and are mirrored in the table
below so the reason is auditable.

| Trivy ID | Resource | Finding | Justification |
|----------|----------|---------|---------------|
| _None_   |          |         |               |

To add an exception: add an entry to `.trivyignore.yaml` (`id`, optional `paths` to scope it, and a
`statement` recording why), then add a matching row here. Where the finding is out of this module's
scope, point the justification at the Libre DevOps module that does address it (for example the
private-endpoint module). Both the file and this table are reviewed in the pull request.

## Reference

The Requirements, Providers, Inputs, Outputs, and Resources below are generated by `terraform-docs`.
