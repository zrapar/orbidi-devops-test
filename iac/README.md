# Terraform Automation Scripts

## Overview

This repository contains a set of Python scripts to automate various tasks related to Terraform, including formatting, initializing, planning, applying, destroying, and cleaning up configurations. These scripts streamline the management of Terraform environments and modules.

## Prerequisites

Before using these scripts, ensure that the following requirements are met:
- Python 3.x installed on your system.
- Terraform CLI installed and available in the system PATH.
- Proper directory structure with `environments`, `global`, and `modules` folders.

## Scripts

### 1. `format.py`

**Purpose**: Formats all Terraform files (`.tf`) in the specified directories.

**Usage**:
```bash
python format.py
```
This script recursively scans the `environments`, `global`, and `modules` directories and formats all `.tf` files using `terraform fmt`.

---

### 2. `init.py`

**Purpose**: Initializes Terraform for specific environments and modules.

**Usage**:
```bash
python init.py -e <environment> -m <module> -b <backend> [--migrate] [--reconfigure] [--upgrade]
```

**Arguments**:
- `-e` or `--environment`: Specify the environment (`development`, `production`).
- `-m` or `--module`: Specify the module (`core`, `data`, `services`, `all`).
- `-b` or `--backend`: Specify the backend (e.g., `s3`).
- `--migrate`: Migrate Terraform state.
- `--reconfigure`: Reconfigure the backend.
- `--upgrade`: Upgrade modules/plugins.

If arguments are missing, the script will prompt for interactive input.

---

### 3. `plan.py`

**Purpose**: Generates a Terraform execution plan for specific environments and modules.

**Usage**:
```bash
python plan.py -e <environment> -m <module> [-o <output_file>] [--refresh-only]
```

**Arguments**:
- `-e` or `--environment`: Specify the environment (`development`, `production`).
- `-m` or `--module`: Specify the module (`core`, `data`, `services`, `all`).
- `-o` or `--output`: Specify the name of the output plan file.
- `--refresh-only`: Refresh the state without making any changes.

---

### 4. `apply.py`

**Purpose**: Applies Terraform changes for specific environments and modules.

**Usage**:
```bash
python apply.py -e <environment> -m <module> [--force] [--save-output] [--refresh-only]
```

**Arguments**:
- `-e` or `--environment`: Specify the environment (`development`, `production`).
- `-m` or `--module`: Specify the module (`core`, `data`, `services`, `all`).
- `--force`: Auto-approve the changes without prompting.
- `--save-output`: Save Terraform output to a JSON file.
- `--refresh-only`: Refresh the state without applying changes.

---

### 5. `destroy.py`

**Purpose**: Destroys Terraform-managed infrastructure for specific environments and modules.

**Usage**:
```bash
python destroy.py -e <environment> -m <module> [--force]
```

**Arguments**:
- `-e` or `--environment`: Specify the environment (`development`, `production`).
- `-m` or `--module`: Specify the module (`core`, `data`, `services`).
- `--force`: Auto-approve the destruction without prompting.

---

### 6. `clean.py`

**Purpose**: Cleans up Terraform-related files, such as `.terraform` directories and lock files.

**Usage**:
```bash
python clean.py -e <environment> -m <module>
```

**Arguments**:
- `-e` or `--environment`: Specify the environment (`development`, `production`, `all`).
- `-m` or `--module`: Specify the module (`core`, `data`, `services`, `all`).

The script removes `.terraform` directories and `.terraform.lock.hcl` files.

---

## Directory Structure

Ensure your project has the following structure:

```
.
├── environments/
│   ├── development/
│   │   ├── core/
│   │   ├── data/
│   │   └── services/
│   ├── production/
│   │   ├── core/
│   │   ├── data/
│   │   └── services/
├── global/
├── modules/
├── format.py
├── init.py
├── plan.py
├── apply.py
├── destroy.py
├── clean.py
```

## Example Usage

### Initialize Terraform
```bash
python init.py -e development -m core -b s3
```

### Plan Changes
```bash
python plan.py -e production -m data -o my-plan
```

### Apply Changes
```bash
python apply.py -e development -m services --force --save-output
```

### Destroy Infrastructure
```bash
python destroy.py -e production -m core --force
```

### Clean Terraform Files
```bash
python clean.py -e all -m all
```

## Notes

- Ensure that `terraform` is installed and properly configured on your system.
- These scripts are designed to work with the specified directory structure.
