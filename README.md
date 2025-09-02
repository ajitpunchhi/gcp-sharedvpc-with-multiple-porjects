# GCP Shared VPC with Multiple Projects

Terraform configuration for setting up Google Cloud Shared VPC with separate production and development service projects.

## What This Creates

- **Host Project**: Contains the shared VPC network
- **Production Service Project**: For production workloads
- **Development Service Project**: For development workloads
- **Cloud Interconnect**: Partner attachments for on-premises connectivity

## Prerequisites

1. Google Cloud account with billing enabled
2. Organization admin permissions
3. Terraform >= 1.0 installed
4. `gcloud` CLI installed

## Quick Start

### 1. Clone Repository
```bash
git clone <repository-url>
cd gcp-sharedvpc-with-multiple-projects
```

### 2. Get Required Information
```bash
# Find your organization ID
gcloud organizations list

# Find your billing account
gcloud billing accounts list
```

### 3. Create terraform.tfvars
```hcl
host_project_id         = "my-shared-vpc-host"
prod_service_project_id = "my-prod-service"
dev_service_project_id  = "my-dev-service"
organization_id         = "123456789012"
billing_account         = "ABCDEF-123456-ABCDEF"
default_region          = "us-central1"
secondary_region        = "us-east1"
```

### 4. Deploy
```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

## Network Configuration

| Environment | Subnet | Primary CIDR | Pods Range | Services Range |
|-------------|--------|--------------|------------|----------------|
| Production | prod-subnet-01 | 10.1.0.0/24 | 10.10.0.0/16 | 10.20.0.0/16 |
| Production | prod-subnet-02 | 10.2.0.0/24 | 10.11.0.0/16 | 10.21.0.0/16 |
| Development | dev-subnet-01 | 10.3.0.0/24 | 10.30.0.0/16 | 10.40.0.0/16 |
| Development | dev-subnet-02 | 10.4.0.0/24 | 10.31.0.0/16 | 10.41.0.0/16 |

## Files

- `main.tf` - Main infrastructure resources
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `iam.tf` - IAM permissions
- `providers.tf` - Provider configuration

## Common Commands

```bash
# Check deployment status
terraform output

# Verify shared VPC
gcloud compute shared-vpc list-associated-projects <host-project-id>

# List subnets
gcloud compute networks subnets list --project=<host-project-id>

# Destroy everything
terraform destroy
```

## Troubleshooting

**Permission Issues**: Ensure you have Organization Admin or Project Creator + Billing Account User roles.

**API Errors**: APIs are automatically enabled, but check if billing is active.

**Project ID Conflicts**: All project IDs must be globally unique in GCP.

## Clean Up

```bash
terraform destroy
```

**Warning**: This will delete all projects and resources. Make sure you have backups of any important data.

## Support

For issues, check the [official GCP documentation](https://cloud.google.com/vpc/docs/shared-vpc) or [Terraform Google Provider docs](https://registry.terraform.io/providers/hashicorp/google/latest/docs).