# Script: clean.py
# Description: Cleans up Terraform-related files, such as `.terraform` directories and lock files, 
# from specified environments and modules. This helps reset the Terraform workspace.

import os
import sys
import shutil

# Current working directory
ACTUAL_PATH = os.getcwd()
# Default list of module folders
FOLDERS = ["core", "data", "services"]
# Default list of environments
ENVS = ["development", "production"]

def validate_input():
    """
    Validates the provided inputs for environment and module.
    Exits the script if any validation fails.
    """
    if not environment or not module:
        print("Error: Missing variables, please check.")
        sys.exit(1)

    valid_environments = ["development", "production", "all"]
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
    Supports flags for environment and module.
    """
    global environment, module
    args = sys.argv[1:]
    arg_map = {
        "-e": "environment", "--environment": "environment",
        "-m": "module", "--module": "module"
    }
    
    i = 0
    while i < len(args):
        arg = args[i]
        if arg in arg_map:
            setattr(sys.modules[__name__], arg_map[arg], args[i + 1])
            i += 2
        else:
            i += 1

def select_environment():
    """
    Prompts the user to select an environment interactively if not provided.
    Assigns the selected environment to the global variable.
    """
    global environment
    env_map = {"1": "development", "2": "production", "3": "all"}
    
    print("Select environment:")
    for key, value in env_map.items():
        print(f"{key}) {value.capitalize()}")

    envchoice = input("Enter choice [1-3]: ")
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

if __name__ == "__main__":
    # Initialize global variables for environment and module
    environment = ""
    module = ""

    # Parse command-line arguments
    parse_arguments()

    # Prompt user for missing inputs
    if not environment:
        select_environment()
    if not module:
        select_module()

    # Validate the inputs
    validate_input()

    # Determine the folders and environments to process
    selected_folders = FOLDERS if module == "all" else [module]
    selected_envs = ENVS if environment == "all" else [environment]

    # Iterate through each environment and module to clean up files
    for env in selected_envs:
        ENV_PATH = os.path.join(ACTUAL_PATH, "environments", env)
        if os.path.isdir(ENV_PATH):  # Ensure the environment path exists
            os.chdir(ENV_PATH)
            for folder in selected_folders:
                # Walk through the directory tree
                for root, dirs, files in os.walk(folder):
                    # Remove `.terraform.lock.hcl` files
                    for file in files:
                        if file == ".terraform.lock.hcl":
                            element = os.path.join(root, file)
                            if os.path.isfile(element):
                                os.remove(element)
                                print(f"Deleted {element}")
                    # Remove `.terraform` directories
                    for directory in dirs:
                        if directory == ".terraform":
                            element = os.path.join(root, directory)
                            if os.path.exists(element):
                                shutil.rmtree(element)
                                print(f"Deleted {element}")
