# Script: init.py
# Description: Automates the initialization of Terraform for specific environments and modules.
# This script supports selecting backends, reconfiguration, and migration options.

import os
import sys

# Global variables for script configuration
environment = ""  # Target environment (e.g., "development", "production")
module = ""       # Target module (e.g., "core", "data", "services", "all")
backend = ""      # Backend type (e.g., "s3")
migrate = False   # Whether to migrate the Terraform state
reconfigure = False  # Whether to reconfigure the backend
upgrade = False   # Whether to upgrade modules/plugins

# Predefined module folders and the current working directory
FOLDERS = ["core", "data", "services"]
ACTUAL_PATH = os.getcwd()

def validate_input():
    """
    Validates the input parameters to ensure they are within acceptable values.
    Exits the program if any input is invalid.
    """
    valid_environments = ["development", "production"]
    valid_modules = ["core", "data", "services", "all"]
    valid_backends = ["s3"]

    if environment not in valid_environments:
        print(f"Error: Invalid Environment: {environment}")
        sys.exit(1)
    if module not in valid_modules:
        print(f"Error: Invalid Module: {module}")
        sys.exit(1)
    if backend not in valid_backends:
        print(f"Error: Invalid Backend: {backend}")
        sys.exit(1)

def parse_arguments():
    """
    Parses command-line arguments and assigns them to global variables.
    Supports flags for environment, module, backend, migrate, reconfigure, and upgrade options.
    """
    global environment, module, backend, migrate, reconfigure, upgrade
    args = sys.argv[1:]
    arg_map = {
        "-e": "environment", "--environment": "environment",
        "-m": "module", "--module": "module",
        "-b": "backend", "--backend": "backend",
        "--migrate": "migrate", "--reconfigure": "reconfigure", "--upgrade": "upgrade"
    }

    i = 0
    while i < len(args):
        arg = args[i]
        if arg in arg_map:
            if arg in ["-e", "-m", "-b", "--environment", "--module", "--backend"]:
                setattr(sys.modules[__name__], arg_map[arg], args[i + 1])
                i += 2
            else:
                setattr(sys.modules[__name__], arg_map[arg], True)
                i += 1
        else:
            i += 1

def select_environment():
    """
    Prompts the user to select an environment interactively.
    Returns:
        str: Selected environment.
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
        str: Selected module.
    """
    module_map = {"1": "core", "2": "data", "3": "services", "4": "all"}
    print("\nSelect module:")
    for key, value in module_map.items():
        print(f"{key}) {value.capitalize()}")
    modulechoice = input("Enter choice [1-4]: ")
    return module_map.get(modulechoice, None)

def select_backend():
    """
    Prompts the user to select a backend interactively.
    Returns:
        str: Selected backend.
    """
    backend_map = {"1": "s3"}
    print("\nSelect backend:")
    for key, value in backend_map.items():
        print(f"{key}) {value.capitalize()}")
    backendchoice = input("Enter choice [1-4]: ")
    return backend_map.get(backendchoice, None)

if __name__ == "__main__":
    # Parse command-line arguments
    parse_arguments()

    # Ensure conflicting options are not selected
    if migrate and reconfigure:
        print("You can't select both options --migrate --reconfigure")
        sys.exit(1)

    # Prompt user for missing inputs
    if not environment:
        environment = select_environment()
    if not module:
        module = select_module()
    if not backend:
        backend = select_backend()

    # Validate the inputs
    validate_input()

    # Adjust FOLDERS if a specific module is selected
    if module != "all":
        FOLDERS = [module]
        
    # Define the Terraform environment path
    ENV_PATH = os.path.join(ACTUAL_PATH, "environments", environment)

    # Construct the Terraform init command
    terraform_command = f"terraform init -backend-config=../../../configs/backends/{backend}.conf -var-file=../{environment}.tfvars"
    if migrate:
        terraform_command += " -migrate-state"
    if reconfigure:
        terraform_command += " -reconfigure"
    if upgrade:
        terraform_command += " -upgrade"

    # Run Terraform initialization for each folder
    for folder in FOLDERS:
        os.chdir(os.path.join(ENV_PATH, folder))
        print(f"\nInitializing Terraform for environment: {environment} in Module {folder}")
        os.system("terraform fmt")
        os.system(terraform_command)
