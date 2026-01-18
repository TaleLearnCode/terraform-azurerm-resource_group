# Changelog

## v0.2.5

- c662393: Merge pull request #2 from TaleLearnCode/dependabot/github_actions/actions/checkout-6
- 6b02f3d: Bump actions/checkout from 4 to 6


## v0.2.4

- 38e2e48: Merge pull request #3 from TaleLearnCode/dependabot/github_actions/terraform-linters/setup-tflint-6
- f14bb3d: Bump terraform-linters/setup-tflint from 4 to 6


## v0.2.3

- d15a75a: Merge pull request #4 from TaleLearnCode/dependabot/github_actions/github/codeql-action-4
- efc9aa8: Bump github/codeql-action from 3 to 4


## v0.2.2

- 4a24d35: Merge pull request #5 from TaleLearnCode/dependabot/github_actions/actions/download-artifact-7
- fadbbb5: Bump actions/download-artifact from 4 to 7


## v0.2.1

- b222178: Merge pull request #6 from TaleLearnCode/dependabot/github_actions/actions/github-script-8
- c4afa78: Bump actions/github-script from 7 to 8


## v0.2.0

- 8b7f91d: Merge pull request #7 from TaleLearnCode/features/Rebuild
- a1fff65: Reorganize output variables: move from output.tf to outputs.tf and ensure proper formatting
- 8120044: Refactor TFLint and TFSec steps in CI workflow: change output format to compact, remove SARIF uploads, and streamline security scan process
- 5796e15: Fix indentation in lock_custom_name test case variables
- 115359f: Add example for selecting Azure region by display name using AVM
- 62d094b: Add subscription_id variable to Terraform Plan step in CI workflow
- 3c21eee: Update GitHub Actions documentation, change license to MIT, update README links, remove outdated example, and improve variable validation error message


## v0.1.0

- 45834fe: Merge pull request #1 from TaleLearnCode/features/Rebuild
- 81fc1b6: Add examples and tests for Azure Resource Group module


All notable changes to this Terraform module will be documented in this file.

## 0.1.0 - 2026-01-17

### Added

- Complete module rebuild with enhanced features
- Management lock support with `azurerm_management_lock` resource
  - Supports lock kinds: `None`, `CanNotDelete`, `ReadOnly`
  - Optional custom lock naming (defaults to `{resource-group-name}-lock`)
- Location validation against Azure Verified Modules (AVM) regions utility
  - Uses `Azure/avm-utl-regions/azurerm` module for accurate region mapping
  - Lifecycle precondition ensures only valid Azure regions are accepted
- Comprehensive module outputs:
  - Resource group ID
  - Resource group name
- Three production-ready examples:
  - **basic:** Minimal configuration with optional tags
  - **locked:** Demonstrates management lock protection (CanNotDelete/ReadOnly)
  - **region-by-display-name:** Safe region selection using display names
- Complete test suite with 3 test cases:
  - `basic_no_lock` - Verifies RG creation without locks
  - `lock_default_name` - Verifies lock creation with auto-generated naming
  - `lock_custom_name` - Verifies lock creation with custom names
- GitHub Actions CI/CD pipelines:
  - **validate.yml** - Code quality, TFLint, TFSec, CodeQL, module structure validation
  - **test.yml** - Terraform tests, example validation, Azure integration
  - **release.yml** - Automated semantic versioning and GitHub releases
  - **quality.yml** - Daily vulnerability scans (Trivy, TruffleHog), documentation checks
- Configuration files:
  - `.tflint.hcl` - TFLint terraform plugin configuration
  - `.tfsec.yaml` - TFSec security scanning configuration
  - `.github/dependabot.yml` - Automated dependency updates
- Comprehensive documentation:
  - Main README.md with usage guide
  - examples/README.md with example index and selection guide
  - .github/GitHubActions.md with workflow documentation
  - CICD_SETUP.md with pipeline configuration guide

### Changed

- Complete overhaul of module structure and variables
- Enhanced input validation with lifecycle preconditions
- Improved documentation and examples

### Breaking Changes

This is a rebuild release with significant structural changes from the pre-release.

## [0.0.1-pre] - 2024-10-09

### Added

- Initial release of the module