# Script: destroy.py
# Description: Automates the destruction of Terraform-managed infrastructure.
# This script supports the deletion of specific environments and modules with options for auto-approval.

import os
import sys

# Global variables for configuration
environment = ""  # Target environment (e.g., "development", "production")
module = ""       # Target module (e.g., "core", "data", "services")
force = False     # Flag to enable auto-approve for Terraform destroy

def parse_arguments():
    """
    Parses command-line arguments and assigns them to global variables.
    Supports flags for environment, module, and auto-approve options.
    """
    global environment, module, force
    args = sys.argv[1:]
    arg_map = {
        "-e": "environment", "--environment": "environment",
        "-m": "module", "--module": "module",
        "--force": "force"
    }

    i = 0
    while i < len(args):
        arg = args[i]
        if arg in arg_map:
            if arg in ["-e", "--environment", "-m", "--module"]:
                setattr(sys.modules[__name__], arg_map[arg], args[i + 1])
                i += 2
            else:
                force = True
                i += 1
        else:
            i += 1

def select_environment():
    """
    Prompts the user to select an environment interactively.
    Returns:
        str: The selected environment.
    """
    env_map = {"1": "development", "2": "production"}
    
    print("Select environment:")
    for key, value in env_map.items():
        print(f"{key}) {value.capitalize()}")

    envchoice = input("Enter choice [1-2]: ")
    return env_map.get(envchoice, None)

def select_module():
    """
    Prompts the user to select a module interactively.
    Returns:
        str: The selected module.
    """
    module_map = {"1": "core", "2": "data", "3": "services"}
    
    print("\nSelect module:")
    for key, value in module_map.items():
        print(f"{key}) {value.capitalize()}")

    modulechoice = input("Enter choice [1-3]: ")
    return module_map.get(modulechoice, None)

def delete_output_file():
    """
    Deletes the Terraform output file for the specified environment and module.
    """
    output_file = f"../{environment}-{module}-output.json"
    if os.path.isfile(output_file):
        os.remove(output_file)
        print(f"Deleted output file: {output_file}")

if __name__ == "__main__":
    # Parse command-line arguments
    parse_arguments()

    # Valid options for environments and modules
    valid_environments = ["development", "production"]
    valid_modules = ["core", "data", "services"]

    # Prompt for environment if not provided
    if not environment:
        environment = select_environment()
    if environment not in valid_environments:
        print("Invalid Environment selected")
        sys.exit(1)

    # Prompt for module if not provided
    if not module:
        module = select_module()
    if module not in valid_modules:
        print("Invalid Module selected")
        sys.exit(1)

    # Change to the appropriate Terraform environment/module directory
    os.chdir(f"environments/{environment}/{module}")

    # Construct the Terraform destroy command
    terraform_command = f"terraform destroy -var-file=../{environment}.tfvars"
    terraform_message = f"Destroying Terraform changes for environment: {environment} in Module {module}"

    # Add auto-approve flag if force is enabled
    if force:
        terraform_command += " -auto-approve"
        terraform_message += " with auto-approve"

    # Execute the Terraform destroy command
    print(f"\n{terraform_message}")
    os.system(terraform_command)

    # Delete the output file after destruction
    delete_output_file()
