# Script: apply.py
# Description: Automates the application of Terraform configurations.
# It allows users to apply changes for specific environments and modules, save outputs, and clean sensitive data.

import os
import sys
import json

# Global variables for configuration
environment = ""  # Target environment (e.g., "development", "production")
module = ""       # Target module (e.g., "core", "data", "services", "all")
force = False     # Auto-approve flag for Terraform apply
save_output = False  # Flag to save the Terraform output
refresh_only = False  # Refresh the Terraform state without applying changes

def validate_input():
    """
    Validates the provided inputs for environment and module.
    Exits the script if any validation fails.
    """
    if not environment or not module:
        print("Error: Missing variables, please check.")
        sys.exit(1)

    valid_environments = ["development", "production"]
    valid_modules = ["core", "data", "services", "all"]

    if environment not in valid_environments:
        print(f"Error: Invalid Environment: {environment}")
        sys.exit(1)

    if module not in valid_modules:
        print(f"Error: Invalid Module: {module}")
        sys.exit(1)

def parse_arguments():
    """
    Parses command-line arguments and assigns them to global variables.
    Supports flags for environment, module, auto-approve, save-output, and refresh-only options.
    """
    global environment, module, force, save_output, refresh_only
    args = sys.argv[1:]
    arg_map = {
        "-e": "environment", "--environment": "environment",
        "-m": "module", "--module": "module",
        "--force": "force", "--save-output": "save_output", "--save": "save_output",
        "-r": "refresh_only", "--refresh-only": "refresh_only"
    }

    i = 0
    while i < len(args):
        arg = args[i]
        if arg in arg_map:
            if arg in ["-e", "--environment", "-m", "--module"]:
                setattr(sys.modules[__name__], arg_map[arg], args[i + 1])
                i += 2
            elif arg in ["-r", "--refresh-only"]:
                refresh_only = True
                i += 1
            else:
                setattr(sys.modules[__name__], arg_map[arg], True)
                i += 1
        else:
            i += 1

def select_environment():
    """
    Prompts the user to select an environment interactively if not provided.
    Assigns the selected environment to the global variable.
    """
    global environment
    env_map = {"1": "development", "2": "production"}
    
    print("Select environment:")
    for key, value in env_map.items():
        print(f"{key}) {value.capitalize()} ({value})")

    envchoice = input("Enter choice [1-2]: ")
    environment = env_map.get(envchoice)
    if not environment:
        print("Invalid choice")
        sys.exit(1)

def select_module():
    """
    Prompts the user to select a module interactively if not provided.
    Assigns the selected module to the global variable.
    """
    global module
    module_map = {"1": "core", "2": "data", "3": "services", "4": "all"}
    
    print("\nSelect module:")
    for key, value in module_map.items():
        print(f"{key}) {value.capitalize()}")

    modulechoice = input("Enter choice [1-4]: ")
    module = module_map.get(modulechoice)
    if not module:
        print("Invalid choice")
        sys.exit(1)

def clean_terraform_output(output_file):
    """
    Cleans sensitive data in the Terraform output file.
    Extracts the 'value' property from JSON objects and saves the cleaned data.
    """
    try:
        with open(output_file, 'r') as file:
            data = json.load(file)

        def transform_dict(d):
            return {key: value['value'] if isinstance(value, dict) and 'value' in value else value for key, value in d.items()}

        cleaned_data = transform_dict(data)

        with open(output_file, 'w') as file:
            json.dump(cleaned_data, file, indent=2)

        print(f"Cleaned sensitive data and moved 'value' properties from {output_file}")

    except Exception as e:
        print(f"Error cleaning output file: {str(e)}")

if __name__ == "__main__":
    # Parse command-line arguments
    parse_arguments()

    # Prompt user for missing inputs
    if not environment:
        select_environment()
    if not module:
        select_module()

    # Validate the inputs
    validate_input()

    # Navigate to the appropriate Terraform environment/module directory
    os.chdir(f"environments/{environment}/{module}")
    terraform_command = f"terraform apply -var-file=../{environment}.tfvars"
    terraform_message = f"Applying Terraform changes for environment: {environment} in Module {module}"

    # Add auto-approve flag if enabled
    if force:
        terraform_command += " -auto-approve"
        terraform_message += " with auto-approve"

    print(terraform_message)
    os.system(terraform_command)

    # Save and clean Terraform output if enabled
    if save_output:
        print("Saving Output")
        output_file = f"../{environment}-{module}-output.json"
        if os.path.isfile(output_file):
            open(output_file, 'w').close()
        os.system(f"terraform output -json >> {output_file}")
        clean_terraform_output(output_file)
