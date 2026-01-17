# GitHub Actions CI/CD Documentation

This document describes the GitHub Actions workflows configured for this Terraform module repository.

## Overview

The repository includes four automated workflows that enforce code quality, security, testing, and release management standards.

| Workflow | File | Purpose | Frequency |
|----------|------|---------|-----------|
| **Validate** | [workflows/validate.yml](#validate) | Code quality & security checks | PR, push, manual |
| **Test** | [workflows/test.yml](#test) | Terraform testing & validation | PR, push, manual |
| **Release** | [workflows/release.yml](#release) | Automated versioning & releases | Push to main, manual |
| **Quality** | [workflows/quality.yml](#quality) | Vulnerability & dependency scanning | PR, push, daily, manual |

---

## Validate Workflow {#validate}

**File:** `.github/workflows/validate.yml`

### Purpose
Ensures code quality, format consistency, and validates Terraform configurations before merge.

### Trigger Events
- Pull Request: opened, synchronize, reopened
- Push to main branch
- Manual (workflow_dispatch)

### Jobs

#### 1. Code Quality
**Runs:** `ubuntu-latest`

Validates Terraform syntax and formatting:
- `terraform init -backend=false` - Initialize without backend
- `terraform fmt -check -recursive` - Verify consistent formatting
- `terraform validate` - Validate syntax
- `tflint` - Lint checks with SARIF output

**Artifacts:**
- `tflint.sarif` - TFLint findings in SARIF format (uploaded to Security tab)

**Failure Condition:** Any step fails if code doesn't meet standards

---

#### 2. Security Scan (TFSec)
**Runs:** `ubuntu-latest`

Security scanning for infrastructure code:
- Scans all Terraform files for security misconfigurations
- Outputs SARIF report for GitHub Security tab

**Artifacts:**
- `tfsec.sarif` - Security findings in SARIF format

**Permissions Required:**
- `security-events: write` - Upload SARIF reports

---

#### 3. CodeQL Analysis
**Runs:** `ubuntu-latest`

GitHub's semantic code analysis:
- Initializes CodeQL database
- Analyzes code for vulnerabilities
- Runs autobuild for supported languages

**Languages Analyzed:**
- C/C++, Python, JavaScript, Ruby, Java, Go, C#

**Permissions Required:**
- `security-events: write` - Upload analysis results

---

#### 4. Module Structure Validation
**Runs:** `ubuntu-latest`

Validates repository structure and required files:
- Verifies `README.md` exists in root
- Verifies `examples/` directory exists
- Verifies `tests/` directory exists
- Validates each example has `main.tf`

**Failure Condition:** Any required file/directory is missing

### Expected Behavior

**Success:**
- All format/syntax checks pass
- SARIF reports uploaded (if generated)
- All required files present

**Failure:**
- Formatting issues → Run `terraform fmt -recursive`
- Validation errors → Fix Terraform syntax
- Missing files → Add required directories/files

---

## Test Workflow {#test}

**File:** `.github/workflows/test.yml`

### Purpose
Runs Terraform tests and validates example configurations in Azure.

### Trigger Events
- Pull Request: opened, synchronize, reopened
- Push to main branch
- Manual (workflow_dispatch)

### Environment Variables
- `ARM_SUBSCRIPTION_ID` - Set from `TEST_SUBSCRIPTION_ID` secret

### Required Secrets
- `TEST_SUBSCRIPTION_ID` - Azure subscription ID
- `AZURE_CREDENTIALS` - Azure service principal JSON

### Jobs

#### 1. Terraform Test
**Runs:** `ubuntu-latest`

Executes `terraform test` command:
- Initializes backend-free
- Runs all tests in verbose mode
- Continues on error (non-blocking)

**Commands:**
```bash
terraform init -backend=false
terraform test -verbose
```

**Artifacts:**
- Terraform test logs
- `.terraform.lock.hcl` files
- `crash.log` if tests crash

**Retention:** 30 days

**Example Test Files:**
- `tests/basic.tftest.hcl` - Tests basic configuration

---

#### 2. Examples Validation
**Runs:** `ubuntu-latest`

Validates each example directory:

**Matrix Strategy:**
```yaml
strategy:
  matrix:
    example:
      - basic
      - locked
      - region-by-display-name
  fail-fast: false  # Runs all examples even if one fails
```

**For Each Example:**
1. Azure Login (using AZURE_CREDENTIALS)
2. `terraform init` - Initialize working directory
3. `terraform validate` - Validate syntax
4. `terraform plan` - Generate plan

**Artifacts (per example):**
- `example-plans-{example-name}` - Terraform plan file
- Retention: 5 days

**Permissions Required:**
- `id-token: write` - For OIDC authentication
- `contents: read`

---

#### 3. Test Summary
**Runs:** `ubuntu-latest`

Aggregates test results and comments on PRs:

**Steps:**
1. Downloads all artifacts
2. Creates GitHub Step Summary with results
3. Comments on PR with test results (if PR)

**GitHub Step Summary Content:**
- Terraform test results
- Example validation status
- Artifact list

**PR Comment Example:**
```
## ✅ Test Results

All validation checks passed:
- Terraform tests executed
- Example configurations validated
- Plans generated successfully

View artifacts for detailed test logs.
```

**Permissions Required:**
- `pull-requests: write` - Create comments on PRs

---

### Test Failure Handling

**Terraform Tests Fail:**
- Step continues (continue-on-error: true)
- Logs uploaded to artifacts
- Check artifacts for detailed error messages

**Example Validation Fails:**
- Matrix continues (fail-fast: false)
- All examples attempt validation
- Summary reports which examples failed

**Azure Authentication Fails:**
- Verify AZURE_CREDENTIALS secret format
- Verify service principal has required permissions
- Check subscription ID matches TEST_SUBSCRIPTION_ID

---

## Release Workflow {#release}

**File:** `.github/workflows/release.yml`

### Purpose
Automates semantic versioning, changelog generation, and GitHub releases.

### Trigger Events
- Push to main branch
- Manual (workflow_dispatch with optional version input)

### Permissions
- `contents: write` - Create tags, commits, releases

### Version Strategy

**Semantic Versioning:** `v{MAJOR}.{MINOR}.{PATCH}`

**Version Bump Logic:**

Based on conventional commits since last tag:

| Commit Type | Bump | Example |
|-------------|------|---------|
| `BREAKING CHANGE:` | Major | v1.0.0 → v2.0.0 |
| `feat:` | Minor | v1.0.0 → v1.1.0 |
| `fix:` | Patch | v1.0.0 → v1.0.1 |
| No matches | Patch | v1.0.0 → v1.0.1 |

### Conventional Commits

**Valid Commit Messages:**

```
feat: add support for resource tags
feat!: remove deprecated parameter
BREAKING CHANGE: remove old API

fix: correct location validation
fix: resolve race condition

docs: update README
style: format code
refactor: restructure logic
test: add test coverage
chore: update dependencies
```

### Jobs

#### Release Job
**Runs:** `ubuntu-latest`

**Steps:**

1. **Checkout & Configure Git**
   - Fetches full history
   - Configures git user: `github-actions[bot]`

2. **Get Last Tag**
   - Finds previous release tag
   - Defaults to `v0.0.0` if none exist

3. **Check for [skip release]**
   - Skips if commit message contains `[skip release]`
   - Used by workflow to prevent infinite loops

4. **Analyze Commits**
   - Gets all commits since last tag
   - Determines version bump based on commit types
   - Skipped if `[skip release]` found

5. **Calculate Version**
   - Parses last tag
   - Applies version bump logic
   - Creates new semantic version

6. **Generate Changelog**
   - Extracts commit messages since last tag
   - Formats as changelog entry

7. **Update CHANGELOG.md**
   - Prepends new version entry
   - Maintains previous entries

8. **Commit and Push Tag**
   - Commits CHANGELOG.md with `[skip release]` tag
   - Creates annotated git tag
   - Pushes to origin/main

9. **Create GitHub Release**
   - Creates GitHub Release with:
     - Version as title
     - Formatted changelog
     - Installation instructions

### Outputs

**Created Artifacts:**
- Git tag: `v{major}.{minor}.{patch}`
- Git commit: Updates CHANGELOG.md
- GitHub Release with installation guide

**Release Body Example:**
```markdown
## v1.2.0

- abc1234: feat: add support for resource tags
- def5678: fix: correct location validation

## Installation

To use this module in your Terraform configuration:

module "resource_group" {
  source = "terraform-registry-url/azurerm-resource-group/azurerm"
  version = "1.2.0"
  
  name     = "my-resource-group"
  location = "eastus"
  
  tags = {
    environment = "production"
  }
}

For more information, see the README.md.
```

### Release Prevention

**Skip Release with:**
```bash
git commit -m "chore: update dependencies [skip release]"
```

**Use Cases:**
- Non-functional changes (docs, formatting)
- Internal maintenance commits
- Preventing accidental releases

---

## Quality Workflow {#quality}

**File:** `.github/workflows/quality.yml`

### Purpose
Performs continuous security scanning and quality checks on the codebase.

### Trigger Events
- Pull Request: opened, synchronize, reopened
- Push to main branch
- Scheduled: Daily at 2:00 AM UTC
- Manual (workflow_dispatch)

### Scheduled Run
```yaml
schedule:
  - cron: '0 2 * * *'  # 2:00 AM UTC daily
```

### Permissions
- `security-events: write` - Upload vulnerability reports

### Error Handling
All jobs have `continue-on-error: true` (non-blocking)

### Jobs

#### 1. Vulnerability Scan (Trivy)
**Runs:** `ubuntu-latest`

File system security scanning:
- Scans entire repository for vulnerabilities
- Checks for misconfigurations
- Outputs SARIF format for GitHub Security tab

**Artifacts:**
- `trivy-results.sarif` - Vulnerability findings

**Detects:**
- Known vulnerabilities (CVE)
- Misconfigurations
- Secret leaks
- Outdated dependencies

---

#### 2. Secret Detection (TruffleHog)
**Runs:** `ubuntu-latest`

Detects accidentally committed secrets:
- Scans all files for API keys, tokens, credentials
- Only reports verified secrets
- Checks entire git history

**Command:**
```bash
trufflehog fs ./ --json --only-verified
```

**Detections Include:**
- AWS credentials
- Azure storage keys
- Private SSH keys
- API tokens
- Database passwords

---

#### 3. Documentation Check
**Runs:** `ubuntu-latest`

Verifies documentation completeness:

**Checks:**
- ✅ `README.md` exists
- ⚠️ `CONTRIBUTING.md` exists (optional)
- ✅ README contains "Usage" or "Installation" section

**Non-blocking:** Warnings don't fail the workflow

---

#### 4. Dependency Check
**Runs:** `ubuntu-latest`

Validates version constraints:

**Checks:**
- ✅ Terraform version >= 1.9 specified
- ✅ Provider versions use constraint operators (~>, >=)

**Non-blocking:** Recommendations only

---

### Quality Report

Generates step summary with:
- Security scan status
- Secret detection status
- Documentation verification
- Dependency validation

---

## Configuration Files

### .tflint.hcl

TFLint configuration for Terraform linting:

```hcl
plugin "terraform" {
  enabled = true
  version = "0.3.0"
  source  = "github.com/terraform-linters/tflint-ruleset-terraform"
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
}

rule "terraform_comment_syntax" {
  enabled = true
}
```

**Rules Enabled:**
- Required version specifications
- Required provider specifications
- Unused variable/resource detection
- Naming convention enforcement
- Comment syntax validation

---

### .tfsec.yaml

TFSec security scanning configuration:

```yaml
format: sarif
severity: WARNING

exclude:
  - "**/tests/**"
  - "**/.terraform/**"
  - "**/examples/**/*/.terraform/**"
```

**Configuration:**
- Output format: SARIF (for GitHub integration)
- Minimum severity: WARNING
- Excluded paths: Test files, .terraform directories

---

### .github/dependabot.yml

Automated dependency updates:

```yaml
version: 2
updates:
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: weekly
      day: monday
      time: '03:00'
    open-pull-requests-limit: 5

  - package-ecosystem: terraform
    directory: /
    schedule:
      interval: weekly
      day: tuesday
      time: '03:00'
    open-pull-requests-limit: 5
```

**Updates:**
- GitHub Actions: Weekly on Mondays
- Terraform Providers: Weekly on Tuesdays
- Maximum 5 open PRs per ecosystem

---

## Secrets & Variables

### Required Secrets

Configure these in **Settings → Secrets and variables → Actions**

#### TEST_SUBSCRIPTION_ID
- **Type:** Repository Secret
- **Value:** Azure subscription ID (GUID)
- **Format:** `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
- **Used by:** test.yml (example validation)

#### AZURE_CREDENTIALS
- **Type:** Repository Secret
- **Value:** Azure service principal credentials (JSON)
- **Format:**
  ```json
  {
    "clientId": "...",
    "clientSecret": "...",
    "subscriptionId": "...",
    "tenantId": "..."
  }
  ```
- **Used by:** test.yml (Azure login)
- **Permissions Required:**
  - Contributor on subscription (for plan operations)
  - Or: Reader + create/delete RG in sandbox

---

### Environment Variables

Set via workflow files or repository settings:

| Variable | Value | Used by |
|----------|-------|---------|
| `ARM_SUBSCRIPTION_ID` | SECRET: TEST_SUBSCRIPTION_ID | test.yml |
| `ARM_TENANT_ID` | From AZURE_CREDENTIALS | test.yml (implicit) |
| `ARM_CLIENT_ID` | From AZURE_CREDENTIALS | test.yml (implicit) |
| `ARM_CLIENT_SECRET` | From AZURE_CREDENTIALS | test.yml (implicit) |

---

## Permissions Matrix

| Workflow | Job | Required Permissions |
|----------|-----|----------------------|
| validate | code-quality | `contents: read` |
| validate | security-scan | `contents: read`, `security-events: write` |
| validate | codeql | `contents: read`, `security-events: write` |
| validate | module-structure | `contents: read` |
| test | terraform-test | `contents: read` |
| test | examples-validation | `contents: read`, `id-token: write` |
| test | test-summary | `contents: read`, `pull-requests: write` |
| release | release | `contents: write` |
| quality | all | `contents: read`, `security-events: write` |

---

## Action Versions

All workflows use current stable versions:

| Action | Version | Purpose |
|--------|---------|---------|
| actions/checkout | v4 | Clone repository |
| hashicorp/setup-terraform | v3 | Install Terraform |
| actions/upload-artifact | v4 | Store artifacts |
| actions/download-artifact | v4 | Retrieve artifacts |
| github/codeql-action | v3 | CodeQL analysis |
| aquasecurity/tfsec-action | v1.0.6 | TFSec scanning |
| aquasecurity/trivy-action | master | Trivy scanning |
| terraform-linters/setup-tflint | v4 | TFLint setup |
| azure/login | v2 | Azure authentication |
| actions/github-script | v7 | GitHub API scripting |
| trufflesecurity/trufflehog | main | Secret detection |

---

## Workflow Badges

Add status badges to README.md:

```markdown
[![Validate](https://github.com/YOUR-ORG/YOUR-REPO/actions/workflows/validate.yml/badge.svg)](https://github.com/YOUR-ORG/YOUR-REPO/actions/workflows/validate.yml)
[![Test](https://github.com/YOUR-ORG/YOUR-REPO/actions/workflows/test.yml/badge.svg)](https://github.com/YOUR-ORG/YOUR-REPO/actions/workflows/test.yml)
[![Quality](https://github.com/YOUR-ORG/YOUR-REPO/actions/workflows/quality.yml/badge.svg)](https://github.com/YOUR-ORG/YOUR-REPO/actions/workflows/quality.yml)
[![Release](https://github.com/YOUR-ORG/YOUR-REPO/actions/workflows/release.yml/badge.svg)](https://github.com/YOUR-ORG/YOUR-REPO/actions/workflows/release.yml)
```

---

## Workflow Monitoring

### GitHub UI
1. Go to **Actions** tab
2. Select workflow to view
3. Click run to see detailed logs

### Status Checks
Pull requests show workflow status:
- ✅ All checks passed - Ready to merge
- ⏳ In progress - Waiting for completion
- ❌ Failed - Review logs and fix issues

### Step Summary
Each workflow generates a step summary visible in:
- PR: Workflow run details
- Commit: Workflow run details
- GitHub Actions tab: "Summary" tab

---

## Troubleshooting

### Workflow Won't Run
- Check triggers in workflow file
- Verify branch is `main` for push triggers
- Check if file modifications match `push.paths` (if configured)

### Terraform Init Fails
- Verify backend not required: `-backend=false`
- Check provider version constraints
- Review error logs in workflow output

### Azure Login Fails
- Verify AZURE_CREDENTIALS secret format (valid JSON)
- Verify service principal has required permissions
- Check subscription ID matches TEST_SUBSCRIPTION_ID

### Tests Fail
- Review test logs in artifacts
- Check Terraform test syntax in `tests/`
- Verify mock providers in test files

### Release Not Created
- Check commit message doesn't contain `[skip release]`
- Verify branch is `main`
- Check git tags exist: `git tag -l`

---

## Best Practices

### Commit Messages
Follow conventional commits for accurate version bumping:
```
feat: add new feature
fix: resolve bug
BREAKING CHANGE: remove API v1
```

### PR Reviews
- Wait for all workflows to complete
- Review workflow logs for warnings
- Address failing checks before merge

### Release Management
- Use `[skip release]` for non-release commits
- Review CHANGELOG.md before release
- Tag releases manually if workflow fails

### Security
- Never commit secrets (TruffleHog will detect)
- Rotate service principal credentials regularly
- Review SARIF reports in Security tab

---

## Related Documentation

- [Validate Workflow Details](./workflows/validate.yml)
- [Test Workflow Details](./workflows/test.yml)
- [Release Workflow Details](./workflows/release.yml)
- [Quality Workflow Details](./workflows/quality.yml)
- [Module README](../README.md)
- [Module Configuration](../CICD_SETUP.md)

---

## Support

For workflow issues:
1. Check workflow logs in **Actions** tab
2. Review step output for error messages
3. Consult [Troubleshooting](#troubleshooting) section
4. Check GitHub Actions documentation

For module issues:
1. Review module README
2. Check examples in `examples/` directory
3. Run `terraform test -verbose` locally
4. Check module changelog
