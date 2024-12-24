# Script: plan.py
# Description: Automates the Terraform planning process for specific environments and modules.
# The script validates inputs, parses arguments, and executes the `terraform plan` command.

import sys
import os

# Global variables for script configuration
environment = ""  # Target environment (e.g., "development", "production")
module = ""       # Target module (e.g., "core", "data", "services", "all")
out = False       # Flag indicating whether to output a plan file
output_file_name = ""  # Name of the output plan file (if `out` is True)
refresh_only = False   # Flag for refreshing state without making changes

def validate_input():
    """
    Validates the input parameters to ensure they are correct.
    Ensures the environment and module are valid and that required options are set.
    """
    valid_environments = ["development", "production"]
    valid_modules = ["core", "data", "services", "all"]

    if environment not in valid_environments:
        print(f"Error: Invalid Environment: {environment}")
        sys.exit(1)
    if module not in valid_modules:
        print(f"Error: Invalid Module: {module}")
        sys.exit(1)
    if out and not output_file_name:
        print("Error: No output name specified")
        sys.exit(1)

def parse_arguments():
    """
    Parses command-line arguments and assigns them to global variables.
    Supports flags for environment, module, output, and refresh-only options.
    """
    global environment, module, out, output_file_name, refresh_only
    args = sys.argv[1:]  # Exclude the script name
    arg_map = {
        "-e": "environment", "--environment": "environment",
        "-m": "module", "--module": "module",
        "-o": "out", "--output": "output_file_name",
        "-r": "refresh_only", "--refresh-only": "refresh_only"
    }

    i = 0
    while i < len(args):
        arg = args[i]
        if arg in arg_map:
            if arg in ["-e", "--environment", "-m", "--module"]:
                setattr(sys.modules[__name__], arg_map[arg], args[i + 1])
                i += 2
            elif arg in ["-o", "--output"]:
                out = True
                output_file_name = args[i + 1]
                i += 2
            elif arg in ["-r", "--refresh-only"]:
                refresh_only = True
                i += 1
        else:
            i += 1

def select_environment():
    """
    Prompts the user to select an environment interactively if not provided via arguments.
    Returns:
        str: The selected environment.
    """
    env_map = {"1": "development", "2": "production"}
    print("Select environment:")
    for key, value in env_map.items():
        print(f"{key}) {value.capitalize()}")
    envchoice = input("Enter choice [1-2]: ")
    return env_map.get(envchoice)

def select_module():
    """
    Prompts the user to select a module interactively if not provided via arguments.
    Returns:
        str: The selected module.
    """
    module_map = {"1": "core", "2": "data", "3": "services", "4": "all"}
    print("\nSelect module:")
    for key, value in module_map.items():
        print(f"{key}) {value.capitalize()}")
    modulechoice = input("Enter choice [1-3]: ")
    return module_map.get(modulechoice)

if __name__ == "__main__":
    # Parse command-line arguments
    parse_arguments()

    # Prompt user for missing inputs
    if not environment:
        environment = select_environment()
    if not module:
        module = select_module()

    # Validate the inputs
    validate_input()

    # Change directory to the appropriate Terraform environment/module path
    os.chdir(f"environments/{environment}/{module}")
    print(f"\nPlanning Terraform changes for environment: {environment} in Module {module}")

    # Construct the Terraform plan command
    terraform_command = f"terraform plan -var-file=../{environment}.tfvars"
    
    if out:
        terraform_command += f" -out=../{output_file_name}.tfplan"

    # Execute the Terraform plan command
    os.system(terraform_command)
