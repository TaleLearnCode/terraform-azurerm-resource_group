# Terraform Tests

This directory contains Terraform native tests for the Azure Resource Group module.

## Overview

The test suite uses Terraform's native testing framework (introduced in Terraform 1.6) to validate module functionality.

**Test File:** `basic.tftest.hcl`  
**Total Tests:** 3  
**Coverage:** Resource creation, lock configuration, custom naming

## Running Tests

### Run All Tests

```bash
terraform test
```

**Output Example:**
```
tests/basic.tftest.hcl... in progress
  run "basic_no_lock"... pass
  run "lock_default_name"... pass
  run "lock_custom_name"... pass
tests/basic.tftest.hcl... pass

Success! 3 passed, 0 failed.
```

### Run with Verbose Output

Verbose mode shows detailed information about each test:

```bash
terraform test -verbose
```

**Includes:**
- Resource creation details
- Attribute values
- Execution timestamps
- Full error messages if failures occur

### Run Specific Test

Run only one test from the suite:

```bash
terraform test -run=basic_no_lock
```

**Test Names:**
- `basic_no_lock` - Basic resource group creation
- `lock_default_name` - Lock with auto-generated name
- `lock_custom_name` - Lock with custom name

### Run with Pattern Matching

Run tests matching a pattern:

```bash
terraform test -run='lock.*'
```

This runs both `lock_default_name` and `lock_custom_name` tests.

## Test Cases

### 1. basic_no_lock

**Purpose:** Verify basic resource group creation without management locks

**Configuration:**
```hcl
module "resource_group" {
  source = "../"

  name     = "rg-basic"
  location = "eastus"
  
  lock = {
    kind = "None"
    name = null
  }
  
  tags = {
    environment = "dev"
  }
}
```

**What It Tests:**
- ✅ Resource group creation with minimal inputs
- ✅ Tag application
- ✅ Location acceptance
- ✅ No lock resource created when `lock.kind = "None"`

**Expected Behavior:**
- Resource group plan generated successfully
- No management lock created
- Tags applied correctly

**Passes When:**
- RG resource plan valid
- Lock resource count is 0
- Tags are correctly set

---

### 2. lock_default_name

**Purpose:** Verify management lock creation with auto-generated naming

**Configuration:**
```hcl
module "resource_group" {
  source = "../"

  name     = "rg-locked"
  location = "eastus2"
  
  lock = {
    kind = "CanNotDelete"
    name = null  # Auto-generate name
  }
  
  tags = {}
}
```

**What It Tests:**
- ✅ Management lock creation when `lock.kind != "None"`
- ✅ Default lock naming pattern: `{resource-group-name}-lock`
- ✅ Correct lock level (`CanNotDelete`)
- ✅ Lock targeting resource group

**Expected Behavior:**
- Management lock resource created
- Lock name is `rg-locked-lock`
- Lock level is `CanNotDelete`
- Lock scope points to resource group

**Passes When:**
- Lock resource count is 1
- Lock name matches pattern
- Lock level is correct

---

### 3. lock_custom_name

**Purpose:** Verify management lock creation with custom naming

**Configuration:**
```hcl
module "resource_group" {
  source = "../"

  name     = "rg-custom-lock"
  location = "westus2"
  
  lock = {
    kind = "ReadOnly"
    name = "custom-lock-name"  # Custom name
  }
  
  tags = {}
}
```

**What It Tests:**
- ✅ Management lock creation with custom name
- ✅ Custom name is used instead of auto-generated
- ✅ Different lock level (`ReadOnly`)
- ✅ Custom naming for specific lock requirements

**Expected Behavior:**
- Management lock resource created
- Lock name is exactly `custom-lock-name`
- Lock level is `ReadOnly`
- Custom naming works correctly

**Passes When:**
- Lock resource count is 1
- Lock name equals custom name provided
- Lock level is correct

---

## Test Structure

### Test File Format

Tests use `.tftest.hcl` format with the following structure:

```hcl
mock_provider "azurerm" {}

run "test_name" {
  command = plan
  
  module {
    source = "../"
  }
  
  variables {
    # Input variables
  }
}
```

### Key Components

**mock_provider**
- Simulates Azure provider without requiring Azure credentials
- Allows testing without cloud resources
- Faster test execution

**run block**
- Defines a single test case
- Contains: command, module config, variables

**command**
- `plan` - Terraform plan (default, used here)
- `apply` - Terraform apply (not used for basic tests)

**module**
- Specifies module to test
- Points to parent directory `"../"`

**variables**
- Input variable values for test
- Passed to module

---

## Writing New Tests

### Test Template

```hcl
run "descriptive_test_name" {
  command = plan

  module {
    source = "../"
  }

  variables {
    name     = "rg-test"
    location = "eastus"
    lock = {
      kind = "None"
      name = null
    }
    tags = {}
  }
}
```

### Naming Conventions

Use descriptive names reflecting what's tested:
- `basic_no_lock` - Basic without locks
- `with_tags` - Testing tag functionality
- `lock_readonly` - Testing ReadOnly lock
- `multi_region` - Testing multiple regions

**Good:** `lock_with_custom_name`  
**Bad:** `test1`, `test_a`

### Test Checklist

When writing a new test:

- [ ] Give it a descriptive name
- [ ] Document what it tests in comments
- [ ] Use realistic module inputs
- [ ] Test one feature at a time
- [ ] Run locally: `terraform test -run=new_test_name`
- [ ] Verify output is meaningful
- [ ] Update this README.md

### Adding Tests to File

1. **Open** `tests/basic.tftest.hcl`
2. **Add** new `run` block at end
3. **Save** file
4. **Test** locally: `terraform test -run=new_test_name`
5. **Document** in this README

---

## Test Best Practices

### 1. Keep Tests Focused

Each test should verify one feature:

```hcl
# Good: Tests one thing
run "lock_creation" {
  variables {
    lock = {
      kind = "CanNotDelete"
      name = null
    }
  }
}

# Avoid: Tests multiple things
run "lock_and_tags_and_naming" {
  variables {
    lock = {
      kind = "CanNotDelete"
      name = "my-lock"
    }
    tags = { env = "prod" }
    name = "rg-special-001"
  }
}
```

### 2. Use Realistic Values

Test with values similar to real usage:

```hcl
# Good: Realistic values
variables {
  name     = "rg-production-001"
  location = "eastus"
}

# Avoid: Cryptic test values
variables {
  name     = "x"
  location = "a"
}
```

### 3. Document Expectations

Add comments explaining what test verifies:

```hcl
# Test that resource group is created successfully
# with location validation passing
run "basic_creation" {
  command = plan
  
  # ...
}
```

### 4. Test Both Success and Failure

Test valid and invalid inputs:

```hcl
# Valid location test
run "valid_location" {
  command = plan
  variables {
    location = "eastus"  # Valid region
  }
}

# Invalid location test (if testing validation)
run "invalid_location" {
  command = plan
  variables {
    location = "not-a-region"  # Invalid
  }
  
  expect_failures = [
    # Expected failure reference
  ]
}
```

### 5. Keep Setup Minimal

Use only required variables:

```hcl
# Good: Minimal, required only
variables {
  name     = "rg-test"
  location = "eastus"
}

# Avoid: Unnecessary variables
variables {
  name     = "rg-test"
  location = "eastus"
  lock = {
    kind = "None"
    name = null
  }
  tags = {}  # Not needed for basic test
}
```

---

## Test Execution

### Local Execution

Run tests locally before committing:

```bash
# Initialize without backend
terraform init -backend=false

# Run all tests
terraform test -verbose

# Run specific test
terraform test -run=basic_no_lock -verbose
```

### CI/CD Execution

Tests automatically run on:
- Pull requests
- Push to main branch
- Manual trigger

**Workflow:** `.github/workflows/test.yml`

**Details:** See [.github/GitHubActions.md](./../.github/GitHubActions.md#test-workflow)

---

## Mock Provider

### What is Mock Provider?

The `mock_provider "azurerm"` simulates Azure provider without:
- Real Azure credentials needed
- Cloud API calls
- Resource creation
- Cost implications

### Benefits

✅ **Fast** - No cloud API calls  
✅ **Safe** - No resources created  
✅ **Offline** - No Azure login required  
✅ **Cheap** - No Azure costs  

### How It Works

1. Mocks provider responses
2. Validates Terraform syntax
3. Checks resource configuration
4. Verifies outputs/values
5. Does NOT create actual resources

### Limitations

- Cannot test actual Azure operations
- Cannot verify Azure-specific behavior
- Mock responses are basic
- Real Azure tests in examples only

---

## Troubleshooting

### Tests Won't Run

**Error:** `No test files found`

**Solution:**
```bash
# Ensure in module root directory
cd /path/to/module

# Verify test file exists
ls tests/basic.tftest.hcl

# Run tests
terraform test
```

---

### Module Not Found

**Error:** `Failed to load module`

**Solution:**
- Verify module source path is correct: `source = "../"`
- Check you're in module root directory
- Verify `main.tf` exists in parent directory

---

### Terraform Not Installed

**Error:** `terraform: command not found`

**Solution:**
```bash
# Install Terraform
# See https://www.terraform.io/downloads

# Verify installation
terraform -v
```

---

### Module Syntax Errors

**Error:** `Error parsing module`

**Solution:**
- Run `terraform fmt -recursive` to format code
- Run `terraform validate` to check syntax
- Review error message for specific issue

---

### Provider Issues

**Error:** `Error: Invalid provider local name`

**Solution:**
- Ensure `mock_provider "azurerm"` configured
- Check provider name spelling
- Verify quotes are straight (not curly)

---

## Test Output

### Successful Run

```bash
$ terraform test -verbose

tests/basic.tftest.hcl... in progress
  run "basic_no_lock"... pass
  run "lock_default_name"... pass
  run "lock_custom_name"... pass
tests/basic.tftest.hcl... pass

Success! 3 passed, 0 failed.
```

### Failed Run

```bash
$ terraform test -verbose

tests/basic.tftest.hcl... in progress
  run "basic_no_lock"... pass
  run "lock_default_name"... fail
╷
│ Error: Mock value not configured
│
│ No mock values were configured for ...
│
└─ on tests/basic.tftest.hcl line 45, in run "lock_default_name":
      45:   variables {
```

**Interpretation:**
- Test name shows which test failed
- Error message indicates the issue
- Line number points to problem location

---

## Advanced Testing

### Testing Multiple Scenarios

Chain multiple `run` blocks for interdependent tests:

```hcl
run "setup_basic_rg" {
  command = plan
  variables {
    name = "rg-test"
    location = "eastus"
  }
}

run "verify_basic_rg" {
  command = plan
  variables {
    # Uses previous test's results
  }
}
```

### Conditional Testing

Skip tests based on conditions (advanced):

```hcl
run "optional_test" {
  command = plan
  
  # Test runs only if condition met
}
```

---

## Integration with CI/CD

### GitHub Actions Integration

Tests run automatically via:

**Workflow:** `.github/workflows/test.yml`

**Triggers:**
- Pull requests
- Push to main
- Manual dispatch

**Steps:**
1. Checkout code
2. Setup Terraform
3. Run `terraform test -verbose`
4. Upload artifacts (logs)
5. Create summary

**View Results:**
- GitHub Actions tab → test.yml
- Pull request → Checks section
- Artifacts tab (for logs)

---

## Maintenance

### Updating Tests

When module changes:

1. **Review** existing tests
2. **Update** if behavior changed
3. **Add** tests for new features
4. **Remove** tests for deprecated features
5. **Run** locally: `terraform test -verbose`
6. **Commit** with conventional commits

### Example: Adding Lock Types

If adding new lock type:

```hcl
run "lock_cannotdelete" {
  command = plan
  variables {
    lock = { kind = "CanNotDelete" }
  }
}

run "lock_readonly" {
  command = plan
  variables {
    lock = { kind = "ReadOnly" }
  }
}

# Add new lock type
run "lock_newtype" {
  command = plan
  variables {
    lock = { kind = "NewType" }
  }
}
```

---

## Resources

### Documentation

- [Terraform Testing Guide](https://developer.hashicorp.com/terraform/language/tests)
- [Test Configuration Language](https://developer.hashicorp.com/terraform/language/test)
- [Mock Providers](https://developer.hashicorp.com/terraform/language/test#mock_provider-blocks)

### Module Documentation

- [Module README](../README.md)
- [Module Variables](../variables.tf)
- [Module Outputs](../output.tf)

### Related Files

- [GitHub Actions Workflows](./../.github/GitHubActions.md)
- [Contributing Guide](../CONTRIBUTING.md)
- [Examples](../examples/)

---

## FAQ

### Q: Do tests require Azure credentials?

**A:** No. Mock provider simulates Azure without credentials.

### Q: How long do tests take?

**A:** Typically 1-5 seconds for mock tests. No cloud API calls means fast execution.

### Q: Can I test actual Azure deployment?

**A:** Tests use mocks. For real Azure tests, see [examples/](../examples/).

### Q: What if a test passes locally but fails in CI/CD?

**A:** 
1. Check Terraform version matches CI/CD
2. Verify test file encoding (UTF-8)
3. Review CI/CD logs for details
4. Run locally with same Terraform version

### Q: How do I test plan output?

**A:** Mock provider doesn't create resources. Use `terraform plan` in examples/ for real planning.

### Q: Can tests modify state?

**A:** No. Mock provider is read-only, no state modified.

---

## Contributing Tests

To contribute new tests:

1. **Create test** in `basic.tftest.hcl`
2. **Run locally** - Verify it passes
3. **Document** - Update this README.md
4. **Commit** - Use conventional commits
5. **Push** - Create pull request

See [CONTRIBUTING.md](../CONTRIBUTING.md) for full guidelines.

---

## Support

For test issues:

1. **Review** this README.md
2. **Check** error messages carefully
3. **Search** existing issues
4. **Ask** in GitHub Discussions
5. **Report** with details and error output

---

**Last Updated:** January 2026  
**Test Framework:** Terraform native testing (1.6+)  
**Coverage:** 3 test cases
