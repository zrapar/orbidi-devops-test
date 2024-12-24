# Infrastructure Setup and Usage Guide

## Prerequisites Setup

Before starting with the infrastructure setup, make sure to configure the necessary values and initialize Terraform.

1. Navigate to the prerequisites directory:
   ```bash
   cd iac/prerequisites
   ```

2. Copy the example Terraform variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. Open `terraform.tfvars` and fill in the required values.

4. Initialize Terraform:
   ```bash
   terraform init
   ```

5. Review the resources to be created:
   ```bash
   terraform plan
   ```

6. Apply the Terraform configuration to create the resources:
   ```bash
   terraform apply
   ```

7. Export the generated keys for use in environments:
   ```bash
   terraform output --json >> keys.json
   ```

## Environment Configuration

Once the prerequisites are set up, configure the necessary backend and environment settings.

1. Navigate to the backends directory:
   ```bash
   cd iac/configs/backends
   ```

2. Copy the example backend configuration:
   ```bash
   cp s3.conf.example s3.conf
   ```

3. Open `s3.conf` and fill in the required values.

4. For setting up the specific environment (development or production), navigate to the appropriate environment directory:
   ```bash
   cd iac/environments/envName
   ```

5. Copy the example environment variables file for the necessary environment:
   ```bash
   cp envName.tfvars.example envName.tfvars
   ```

6. Open `envName.tfvars` and fill in the necessary values.

## Running the Scripts

After configuring the environment, you can proceed with running the Python scripts for initialization, planning, and applying infrastructure changes.

### Initialize Infrastructure
```bash
cd iac
python init.py
```

Alternatively, you can specify the environment, module, and backend:
```bash
python init.py -e development -m moduleName -b Selected_Backend
```

### Plan Infrastructure Changes
```bash
python plan.py -e development -m moduleName
```

### Apply Infrastructure Changes
```bash
python apply.py -e development -m moduleName --save
```

This will apply the changes and save the generated output.

## Destroy Infrastructure

To destroy the created infrastructure and remove the resources:

```bash
python destroy.py -e development -m moduleName --save
```

This will delete the resources and delete the content of the output file.
