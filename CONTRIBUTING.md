# Contributing to Azure Resource Group Terraform Module

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to this project.

## Code of Conduct

This project adheres to the Contributor Covenant [code of conduct](https://www.contributor-covenant.org/). By participating, you are expected to uphold this code.

## How to Contribute

There are many ways to contribute:
- Report bugs
- Suggest features
- Improve documentation
- Write code
- Add tests
- Share examples

## Getting Started

### Prerequisites

Before you begin, ensure you have:
- Terraform >= 1.9
- Azure CLI or Azure account credentials
- Git configured with your name and email
- Basic understanding of Terraform and Azure

### Fork & Clone

1. **Fork the repository**
   ```bash
   # Go to https://github.com/YOUR-ORG/YOUR-REPO
   # Click the "Fork" button
   ```

2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR-USERNAME/YOUR-REPO.git
   cd YOUR-REPO
   ```

3. **Add upstream remote**
   ```bash
   git remote add upstream https://github.com/YOUR-ORG/YOUR-REPO.git
   ```

## Development Workflow

### 1. Create a Feature Branch

Always create a new branch for your changes:

```bash
git checkout -b feature/your-feature-name
```

Branch naming conventions:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `test/` - Test additions
- `refactor/` - Code refactoring
- `chore/` - Maintenance tasks

### 2. Make Your Changes

Follow these guidelines:

#### Code Style
- Use consistent indentation (2 spaces for HCL)
- Follow Terraform naming conventions
- Keep lines reasonably short (80-120 characters)
- Use meaningful variable and resource names

#### Terraform Best Practices
- Use `terraform fmt` for formatting
- Include comments for complex logic
- Use meaningful resource names
- Follow Azure naming conventions
- Avoid hardcoding values

#### Example Change:
```hcl
# Good: Clear, formatted, well-named
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = merge(
    var.tags,
    {
      managed_by = "terraform"
    }
  )
}

# Avoid: Unclear, hardcoded
resource "azurerm_resource_group" "rg" {
  name = "my-rg"
  location = "eastus"
}
```

### 3. Format Your Code

Before committing, format all Terraform files:

```bash
# Format current directory
terraform fmt

# Format recursively
terraform fmt -recursive

# Format specific file
terraform fmt variables.tf
```

### 4. Validate Your Code

Ensure syntax is correct:

```bash
# Initialize without backend
terraform init -backend=false

# Validate syntax
terraform validate

# Lint with TFLint
tflint --init
tflint
```

### 5. Test Your Changes

Add tests for new functionality:

```bash
# Run all tests
terraform test -verbose

# Run specific test
terraform test -run=test_name -verbose
```

#### Writing Tests

Test files go in `tests/` directory with `.tftest.hcl` extension:

```hcl
mock_provider "azurerm" {}

run "my_test" {
  command = plan

  module {
    source = "../"
  }

  variables {
    name     = "test-rg"
    location = "eastus"
  }
}
```

### 6. Test Examples

Validate that examples still work:

```bash
# Test each example
for example in examples/*/; do
  echo "Testing $example"
  cd "$example"
  terraform init
  terraform validate
  terraform plan
  cd -
done
```

### 7. Document Your Changes

Update documentation as needed:

- **Code Comments** - Add comments for complex logic
- **README.md** - Update usage examples if applicable
- **examples/** - Add new examples for new features
- **CHANGELOG.md** - Will be auto-generated, use conventional commits

### 8. Commit Your Changes

Use conventional commit format:

```bash
git add .
git commit -m "feat: add new capability"
```

#### Conventional Commits

Format: `type(scope): description`

**Types:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation update
- `style:` - Code style (formatting)
- `refactor:` - Code refactoring
- `test:` - Test additions
- `chore:` - Maintenance/dependencies
- `perf:` - Performance improvement

**Scope (optional):**
- `vars` - Variable changes
- `docs` - Documentation
- `examples` - Example changes
- `tests` - Test changes

**Examples:**
```bash
git commit -m "feat: add support for custom lock names"
git commit -m "fix: correct location validation logic"
git commit -m "docs: update README with new examples"
git commit -m "test: add test for lock creation"
git commit -m "BREAKING CHANGE: remove deprecated parameter"
```

### 9. Keep Your Branch Updated

Sync with upstream before pushing:

```bash
git fetch upstream
git rebase upstream/main
```

### 10. Push Your Changes

```bash
git push origin feature/your-feature-name
```

## Submitting a Pull Request

### PR Creation

1. **Go to GitHub** and create a Pull Request from your fork to `main`
2. **Use a descriptive title** following conventional commits
3. **Fill out the PR template** with:
   - What changes you made
   - Why you made them
   - How to test the changes
   - Any breaking changes
   - Closes issues (if applicable)

### PR Title Example

```
feat: add support for custom lock names
```

Not:
```
Update module
```

### PR Description Example

```markdown
## Description
Adds support for custom management lock naming instead of only auto-generated names.

## Changes
- Added `name` parameter to lock configuration object
- Updated lock naming logic to use custom name if provided
- Updated tests to verify custom naming

## Testing
- Tested with custom lock name
- Tested with default (auto-generated) lock name
- All existing tests pass

## Breaking Changes
None

## Closes
#123
```

### PR Checks

Before merge, ensure:
- ✅ All CI/CD workflows pass
  - Validate workflow (code quality, security)
  - Test workflow (terraform tests, examples)
  - Quality workflow (vulnerabilities, secrets)
- ✅ Code review approval
- ✅ No merge conflicts
- ✅ Commit history is clean

### PR Review Process

1. **Automated Checks Run**
   - Code formatting check
   - Terraform validation
   - Security scanning
   - Tests execution

2. **Manual Review**
   - Code quality review
   - Best practices check
   - Documentation review
   - Test coverage verification

3. **Approval & Merge**
   - Reviewer approves changes
   - Squash commits if requested
   - Merge to main

## Reporting Bugs

### Before Reporting

1. Check [existing issues](https://github.com/YOUR-ORG/YOUR-REPO/issues)
2. Try the latest version
3. Enable debug logging if helpful

### Bug Report Template

Use the bug report template on GitHub issues with:

**Title:** Clear, concise description
```
Location validation fails for custom regions
```

**Description:**
```markdown
### Expected Behavior
Location validation should accept all regions from AVM module.

### Actual Behavior
Validation fails for certain regions with valid region keys.

### Steps to Reproduce
1. Create resource group with location = "canadacentral"
2. Run terraform plan
3. Observe validation error

### Environment
- Terraform: 1.9.0
- Provider: azurerm 4.0.1
- OS: Ubuntu 20.04

### Additional Info
Works in version 0.0.1
```

## Suggesting Features

### Feature Request Template

**Title:** Clear description of desired feature
```
Support for resource group locking policy
```

**Description:**
```markdown
### Problem
Users need centralized control over lock policies across multiple resource groups.

### Proposed Solution
Add optional `lock_policy` variable to apply organization-level lock standards.

### Alternative Solutions
1. Document workaround with separate lock resources
2. Create separate module for lock policies

### Additional Context
This aligns with Azure governance best practices.
```

## Documentation Improvements

### Types of Documentation
- **README** - Module overview and usage
- **Examples** - Working configuration examples
- **Code Comments** - Complex logic explanation
- **Changelog** - Version history

### Documentation Standards
- Use clear, concise language
- Include code examples
- Link to related documentation
- Follow existing style/format
- Use proper markdown formatting

### Documentation Review
- Someone will review for clarity
- Ensure examples are accurate
- Check for broken links
- Verify code snippets work

## Testing Requirements

### Test Coverage

- All new features must have tests
- Tests must pass: `terraform test`
- Examples must validate
- No reduction in coverage

### Types of Tests

**Unit Tests** - Test individual components
```hcl
run "basic_creation" {
  command = plan
  # Test basic resource creation
}
```

**Integration Tests** - Test component interactions
```hcl
run "with_locks" {
  command = plan
  # Test resource group with management locks
}
```

**Example Tests** - Validate examples work
```bash
cd examples/basic
terraform init
terraform validate
terraform plan
```

### Test Checklist
- [ ] New tests written for new code
- [ ] All tests pass: `terraform test -verbose`
- [ ] Examples validate: `terraform validate`
- [ ] Examples plan successfully: `terraform plan`
- [ ] No test regressions

## Code Review Guidelines

### What Reviewers Look For

✅ **Quality Code**
- Follows style guide
- No unnecessary complexity
- Reuses existing patterns
- Well-commented

✅ **Functionality**
- Solves stated problem
- No obvious bugs
- Handles edge cases
- Backward compatible

✅ **Tests**
- Adequate coverage
- All pass
- No false positives
- Clear assertions

✅ **Documentation**
- Updated as needed
- Clear and accurate
- Examples provided
- Links verified

### Addressing Feedback

1. **Understand the feedback** - Ask for clarification if needed
2. **Discuss if disagreement** - Explain your reasoning
3. **Make requested changes** - Update code as reviewed
4. **Commit changes** - Add new commits (don't force push)
5. **Request re-review** - Mark resolved and ask for re-review

## Release Management

### Version Numbering

Follows [Semantic Versioning](https://semver.org/):

```
MAJOR.MINOR.PATCH
  ↓     ↓      ↓
  1     2      3
```

- **MAJOR** - Breaking changes
- **MINOR** - New features
- **PATCH** - Bug fixes

### Release Process

1. **Commits analyzed** - Tool examines commits since last release
2. **Version determined** - Based on conventional commit types
3. **CHANGELOG updated** - Auto-generated from commits
4. **Tag created** - New semantic version tag
5. **Release published** - GitHub Release created

### Example Release Progression
```
v0.0.1 (initial)
  ↓ (fix: bug fix)
v0.0.2
  ↓ (feat: new feature)
v0.1.0
  ↓ (BREAKING CHANGE)
v1.0.0
```

## CI/CD Pipelines

### Workflows Running on PR

| Workflow | Purpose | Failure Blocks Merge |
|----------|---------|---------------------|
| Validate | Code quality & security | ✅ Yes |
| Test | Terraform tests & examples | ✅ Yes |
| Quality | Vulnerability scans | ❌ No |

### Viewing Results

1. Go to PR page
2. Scroll to "Checks" section
3. Click workflow to see details
4. Review failed steps
5. Make corrections and push again

### Fixing Workflow Failures

**Validate Fails:**
```bash
terraform fmt -recursive
git add .
git commit -m "style: format code"
git push
```

**Test Fails:**
- Review test output in GitHub Actions
- Fix code or test logic
- Run locally: `terraform test -verbose`
- Push corrected code

**Quality Fails (non-blocking):**
- Review warnings
- Fix if necessary
- No action required to merge

## Community Guidelines

### Be Respectful
- Treat others with respect
- Accept constructive criticism
- Assume good intentions
- Communicate clearly

### Be Helpful
- Help newer contributors
- Answer questions patiently
- Share knowledge
- Review others' PRs

### Be Professional
- Keep discussions on-topic
- Focus on technical merit
- Avoid personal attacks
- Report conduct violations

## Getting Help

### Resources

- **Documentation** - See [README.md](./README.md)
- **Examples** - See [examples/](./examples/)
- **Issues** - [GitHub Issues](https://github.com/YOUR-ORG/YOUR-REPO/issues)
- **Discussions** - [GitHub Discussions](https://github.com/YOUR-ORG/YOUR-REPO/discussions)

### Questions?

1. Check existing documentation
2. Search existing issues
3. Ask in GitHub Discussions
4. Open an issue if needed

## Recognition

Contributors are recognized in:
- Release notes (CHANGELOG.md)
- GitHub contributors page
- Thank you messages in releases

We appreciate all contributions, big and small!

## Legal

### License

By contributing, you agree that your contributions will be licensed under the [MIT License](./LICENSE).

### Contributor License Agreement

We require contributors to sign our Contributor License Agreement (CLA). The process is automated when you create your first PR.

## Additional Resources

- [Terraform Best Practices](https://www.terraform.io/docs/cloud/recommended-practices)
- [Terraform Module Conventions](https://www.terraform.io/docs/modules/create)
- [Azure Naming Conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)
- [Semantic Versioning](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)

---

Thank you for contributing! Your efforts help make this project better for everyone. 🙏
