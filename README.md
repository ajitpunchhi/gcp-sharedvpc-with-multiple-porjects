GCP Shared VPC with Multiple Projects
This Terraform configuration creates a Google Cloud Platform (GCP) Shared VPC setup with multiple service projects, including production and development environments, complete with Cloud Interconnect attachments and proper IAM configurations.
📋 Table of Contents

Overview
Architecture
Prerequisites
Project Structure
Setup Instructions
Configuration
Deployment
Post-Deployment
Resource Details
Troubleshooting
Cleanup

🔍 Overview
This infrastructure setup creates:

1 Host Project: Contains the shared VPC network
2 Service Projects: Production and Development environments
Shared VPC Network: With dedicated subnets for each environment
Cloud Interconnect: Partner interconnect attachments for on-premises connectivity
IAM Permissions: Proper network user permissions for service projects
Firewall Rules: Basic security rules for internal communication


✅ Prerequisites
1. GCP Account Setup

Google Cloud Platform account with billing enabled
Organization-level access or appropriate project creation permissions
gcloud CLI installed and configured

2. Terraform Setup

Terraform >= 1.0 installed
Google Provider ~> 4.0

3. Required Permissions
Your account needs the following IAM roles:
- Organization Admin (or Project Creator + Billing Account User)
- Compute Network Admin
- Security Admin
- Service Usage Admin
- Project IAM Admin
4. GCP APIs
The following APIs will be automatically enabled:

Compute Engine API
Cloud Resource Manager API
Service Networking API
Container API (for GKE support)

📁 Project Structure
gcp-sharedvpc-with-multiple-projects/
├── README.md                 # This file
├── main.tf                   # Main infrastructure resources
├── variables.tf              # Variable definitions
├── outputs.tf               # Output definitions
├── providers.tf             # Provider configurations
├── iam.tf                   # IAM permissions
└── terraform.tfvars.example # Example variables file
🚀 Setup Instructions
Step 1: Clone the Repository
bashgit clone <repository-url>
cd gcp-sharedvpc-with-multiple-projects
Step 2: Configure Authentication
bash# Authenticate with GCP
gcloud auth login

# Set application default credentials
gcloud auth application-default login

# Set your project (optional, but recommended for gcloud commands)
gcloud config set project <your-project-id>
Step 3: Create terraform.tfvars
Create a terraform.tfvars file with your specific values:
hcl# Project Configuration
host_project_id         = "shared-vpc-host-prod-001"
prod_service_project_id = "prod-service-001"
dev_service_project_id  = "dev-service-001"

# Organization Configuration
organization_id   = "123456789012"  # Your org ID
billing_account   = "ABCDEF-123456-ABCDEF"  # Your billing account

# Regional Configuration  
default_region    = "us-central1"
secondary_region  = "us-east1"
Step 4: Get Required IDs
Find Organization ID:
bashgcloud organizations list
Find Billing Account:
bashgcloud billing accounts list
Verify Regions:
bashgcloud compute regions list
⚙️ Configuration
Network Configuration
IP Address Ranges:
EnvironmentSubnetPrimary CIDRPods RangeServices RangeProductionprod-subnet-0110.1.0.0/2410.10.0.0/1610.20.0.0/16Productionprod-subnet-0210.2.0.0/2410.11.0.0/1610.21.0.0/16Developmentdev-subnet-0110.3.0.0/2410.30.0.0/1610.40.0.0/16Developmentdev-subnet-0210.4.0.0/2410.31.0.0/1610.41.0.0/16
Interconnect Configuration
VLAN Tags:

Region 1: VLAN 100, 101
Region 2: VLAN 200, 201

BGP ASNs:

Region 1 Router: 65001
Region 2 Router: 65002

🚀 Deployment
Step 1: Initialize Terraform
bashterraform init
Step 2: Plan the Deployment
bashterraform plan
Step 3: Apply the Configuration
bashterraform apply
Note: The deployment will take approximately 5-10 minutes to complete.
Step 4: Verify Deployment
bash# Check the outputs
terraform output

# Verify shared VPC setup
gcloud compute shared-vpc get-host-project <service-project-id>

# List networks
gcloud compute networks list --project=<host-project-id>

# List subnets
gcloud compute networks subnets list --project=<host-project-id>
📋 Post-Deployment
1. Verify Shared VPC Association
bash# Check service projects attached to host
gcloud compute shared-vpc associated-projects list <host-project-id>

# Verify network access for service projects
gcloud compute networks subnets get-iam-policy <subnet-name> \
  --region=<region> --project=<host-project-id>
2. Test Connectivity
Create test instances in service projects:
bash# Create instance in production project
gcloud compute instances create prod-test-vm \
  --project=<prod-service-project-id> \
  --zone=us-central1-a \
  --subnet=projects/<host-project-id>/regions/us-central1/subnetworks/prod-subnet-01

# Create instance in development project  
gcloud compute instances create dev-test-vm \
  --project=<dev-service-project-id> \
  --zone=us-central1-a \
  --subnet=projects/<host-project-id>/regions/us-central1/subnetworks/dev-subnet-01
3. Configure Cloud Interconnect
After deployment, complete the interconnect setup:

Contact your network service provider
Provide the VLAN attachment details (available in terraform outputs)
Configure BGP sessions with the router IP addresses
Test connectivity from on-premises

📊 Resource Details
Projects Created

Host Project: Manages the shared VPC network and interconnect
Production Service Project: For production workloads
Development Service Project: For development workloads

Networks and Subnets

Shared VPC Network: Global network with custom subnets
Production Subnets: In primary and secondary regions
Development Subnets: In primary and secondary regions
Secondary IP Ranges: For GKE pods and services

IAM Permissions

Project-level: roles/compute.networkUser for service project default service accounts
Subnet-level: Granular access for each service project to their respective subnets

Firewall Rules

Internal Traffic: Allow all traffic between 10.0.0.0/8 ranges
SSH Access: Port 22 for instances with ssh-allowed tag
HTTP/HTTPS: Ports 80/443 for instances with web-server tag

Cloud Interconnect

4 VLAN Attachments: 2 per region for redundancy
Partner Interconnect: 1Gbps bandwidth per attachment
BGP Configuration: Separate ASNs for each region

🔧 Troubleshooting
Common Issues
1. Permission Denied Errors
bash# Ensure you have proper organization permissions
gcloud organizations get-iam-policy <org-id>

# Check project creation permissions
gcloud projects get-iam-policy <project-id>
2. API Not Enabled
bash# Manually enable required APIs
gcloud services enable compute.googleapis.com --project=<project-id>
gcloud services enable container.googleapis.com --project=<project-id>
3. Billing Account Issues
bash# Verify billing account access
gcloud billing accounts get-iam-policy <billing-account-id>
4. Quota Exceeded
bash# Check compute quotas
gcloud compute project-info describe --project=<project-id>
Validation Commands
bash# Verify shared VPC configuration
gcloud compute shared-vpc get-host-project <service-project-id>

# Check interconnect attachments
gcloud compute interconnects attachments list --project=<host-project-id>

# Verify subnet IAM
gcloud compute networks subnets get-iam-policy <subnet> \
  --region=<region> --project=<host-project-id>
🧹 Cleanup
To destroy all resources:
bash# Destroy infrastructure
terraform destroy

# Confirm destruction
# Type 'yes' when prompted
⚠️ Warning: This will permanently delete all resources. Ensure you have backups of any important data.
Manual Cleanup (if needed):
bash# Disable shared VPC
gcloud compute shared-vpc disable <host-project-id>

# Delete projects (if needed)
gcloud projects delete <project-id>
📚 Additional Resources

Google Cloud Shared VPC Documentation
Terraform Google Provider Documentation
Cloud Interconnect Documentation
GCP Network Security Best Practices