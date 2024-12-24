# Script: format.py
# Description: Automates formatting of Terraform configuration files.
# It recursively scans specific directories and applies `terraform fmt` to any `.tf` files.

import os
import subprocess

def format_terraform_directories():
    """
    Scans target directories for Terraform files (`.tf`) and applies the `terraform fmt` command.
    Skips directories containing `.terraform`.
    """
    # Get the directory of the script
    root_dir = os.path.dirname(os.path.abspath(__file__))
    # Directories to scan for Terraform files
    target_dirs = ['environments', 'global', 'modules']

    # Iterate through each target directory
    for target_dir in target_dirs:
        target_path = os.path.join(root_dir, target_dir)

        # Walk through the directory tree
        for subdir, _, files in os.walk(target_path):
            # Skip `.terraform` directories to avoid unnecessary processing
            if ".terraform" in subdir:
                continue

            # Check if the current directory contains any `.tf` files
            if any(file.endswith(".tf") for file in files):
                try:
                    # Run `terraform fmt` on the directory
                    subprocess.run(["terraform", "fmt", subdir], check=True)
                    print(f"Formatted: {subdir}")
                except subprocess.CalledProcessError as e:
                    # Handle errors from `terraform fmt`
                    print(f"Error formatting {subdir}: {e}")
                except Exception as e:
                    # Handle any other unexpected errors
                    print(f"Unexpected error formatting {subdir}: {e}")

if __name__ == "__main__":
    # Execute the formatting function when the script is run
    format_terraform_directories()
