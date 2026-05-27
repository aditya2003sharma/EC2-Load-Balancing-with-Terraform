# EC2 Load Balancing with Terraform

A comprehensive Terraform configuration for deploying and managing AWS Application Load Balancers (ALB) with EC2 instances on AWS. This project provides an infrastructure-as-code solution for creating highly available and scalable web applications.

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Features](#features)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Files Description](#files-description)
- [Outputs](#outputs)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)
- [Contributing](#contributing)
- [License](#license)

## 🎯 Overview

This repository contains Terraform configurations to automate the deployment of:
- **AWS Application Load Balancer (ALB)** - For distributing incoming application traffic across multiple targets
- **EC2 Instances** - Web servers configured to run web applications
- **Security Groups** - Network access control for load balancer and instances
- **Target Groups** - Logical grouping of instances for the load balancer
- **VPC & Networking** - Virtual Private Cloud with proper subnet configuration

The setup demonstrates load balancing best practices including health checks, automatic target group management, and multi-AZ deployment.

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

### Required Software
- **Terraform** >= 1.0 (Download from [terraform.io](https://www.terraform.io/downloads.html))
- **AWS CLI** >= 2.0 (Download from [aws.amazon.com/cli](https://aws.amazon.com/cli/))
- **Git** (for cloning the repository)
- **Bash/Shell** (for running scripts)

### AWS Account Requirements
- AWS account with appropriate IAM permissions
- AWS credentials configured locally (via `aws configure`)
- EC2, ALB, VPC, and Security Group permissions

### Recommended
- AWS IAM user with permissions for:
  - EC2 management
  - Load Balancing
  - VPC and Networking
  - CloudWatch monitoring

## 📁 Project Structure

```
EC2-Load-Balancing-with-Terraform/
├── main.tf                    # Main Terraform configuration
├── provider.tf               # AWS provider configuration
├── variables.tf              # Variable definitions
├── userdata.sh               # User data script for EC2 instance 1
├── userdata1.sh              # User data script for EC2 instance 2
├── terraform.tfstate         # Terraform state file (local)
├── terraform.tfstate.backup  # Backup of state file
└── README.md                 # This file
```

## ✨ Features

- **Infrastructure as Code**: Complete infrastructure defined in HCL
- **Automated Deployment**: Single command to deploy entire infrastructure
- **Load Balancing**: Application Load Balancer distributes traffic across instances
- **Health Checks**: Automatic health monitoring of EC2 instances
- **High Availability**: Multi-AZ deployment support
- **Security**: Security groups and network access control
- **Custom Scripts**: User data scripts for EC2 initialization
- **State Management**: Terraform state management with backups
- **Easy Cleanup**: Destroy entire infrastructure with single command

## 🚀 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/aditya2003sharma/EC2-Load-Balancing-with-Terraform.git
cd EC2-Load-Balancing-with-Terraform
```

### 2. Initialize Terraform

```bash
terraform init
```

This command initializes the Terraform working directory and downloads the AWS provider plugin.

### 3. Plan the Deployment

```bash
terraform plan
```

Review the planned changes before applying them. This shows all resources that will be created.

### 4. Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted to confirm and create the infrastructure.

### 5. Auto-Approve (Optional)

To skip the confirmation prompt:

```bash
terraform apply -auto-approve
```

## ⚙️ Configuration

### Environment Variables

Set AWS credentials before running Terraform:

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"  # or your preferred region
```

Or configure using AWS CLI:

```bash
aws configure
```

### Terraform Variables

Edit the `variables.tf` file to customize:
- AWS region
- VPC and subnet CIDR blocks
- Instance types and counts
- Load balancer configuration
- Health check parameters
- Tags and naming conventions

Example:
```hcl
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_count" {
  type    = number
  default = 2
}
```

## 📖 Usage

### Full Deployment

```bash
# Initialize
terraform init

# Review changes
terraform plan

# Apply configuration
terraform apply

# View outputs
terraform output
```

### Get Load Balancer DNS

```bash
terraform output alb_dns_name
```

Access your application at:
```
http://<ALB_DNS_NAME>
```

### View Instance Details

```bash
# List all resources
terraform state list

# Show specific resource
terraform state show aws_instance.web[0]
```

### Update Configuration

Modify `variables.tf` or add new resources, then:

```bash
terraform plan
terraform apply
```

### Scale Up/Down

Change the instance count in `variables.tf`:

```hcl
variable "instance_count" {
  type    = number
  default = 3  # Increase or decrease as needed
}
```

Then apply:

```bash
terraform apply
```

### Destroy Infrastructure

**Warning**: This will delete all resources. Ensure you have backups if needed.

```bash
terraform destroy
```

Or with auto-approval:

```bash
terraform destroy -auto-approve
```

### Clean Up Files

After destroying, optionally remove Terraform files:

```bash
rm -rf .terraform/
rm -f terraform.tfstate*
```

## 📄 Files Description

### main.tf
Contains the primary Terraform configuration including:
- VPC and networking resources
- EC2 instances with auto-scaling capabilities
- Application Load Balancer setup
- Target groups and listeners
- Security group rules and configurations
- Health check configurations

### provider.tf
Defines AWS provider settings:
- AWS region specification
- API version
- Required provider version constraints

### variables.tf
Declares all input variables:
- AWS region
- Instance types and counts
- VPC CIDR blocks
- Load balancer settings
- Health check parameters
- Tags for resource management

### userdata.sh
Bash script executed on first EC2 instance launch:
- System package updates
- Web server (Apache/Nginx) installation
- Application deployment
- Service initialization

### userdata1.sh
Similar to `userdata.sh` but for second instance:
- May contain different configurations
- Useful for testing multiple versions
- Can be used for canary deployments

### terraform.tfstate
Manages infrastructure state:
- **DO NOT** commit to version control
- Contains sensitive information
- Use remote state in production
- Backup maintained in `.tfstate.backup`

## 📊 Outputs

After successful deployment, Terraform provides:

```bash
# Application Load Balancer DNS Name
alb_dns_name = "my-alb-1234567890.us-east-1.elb.amazonaws.com"

# Target Group ARN
target_group_arn = "arn:aws:elasticloadbalancing:..."

# EC2 Instance IDs
instance_ids = ["i-0123456789abcdef0", "i-0123456789abcdef1"]

# Security Group ID
security_group_id = "sg-0123456789abcdef0"
```

Access your application using the ALB DNS name:
```
http://my-alb-1234567890.us-east-1.elb.amazonaws.com
```

## 🔧 Troubleshooting

### Common Issues and Solutions

#### 1. Terraform Command Not Found
```bash
# Ensure Terraform is installed and in PATH
terraform --version

# Add to PATH if needed
export PATH="$PATH:/path/to/terraform"
```

#### 2. AWS Credentials Error
```bash
# Verify credentials are configured
aws sts get-caller-identity

# Reconfigure credentials
aws configure
```

#### 3. Instances Showing as Unhealthy
- Wait 2-3 minutes for instances to fully boot
- Check security group allows traffic from ALB
- Verify user data scripts completed successfully
- Check EC2 instance system logs

```bash
# Check instance status
aws ec2 describe-instance-status --instance-ids i-xxxxx
```

#### 4. Load Balancer DNS Not Accessible
- Ensure security group allows HTTP (port 80) inbound traffic
- Verify instances are in the target group and healthy
- Check that listener rules are properly configured
- Test from AWS console or within VPC

#### 5. Port Already in Use
- Change the ALB listener port in `main.tf`
- Ensure no other services use ports 80 and 443

#### 6. VPC CIDR Block Conflicts
- Modify VPC CIDR in `variables.tf` if conflicts exist
- Ensure subnets don't overlap with existing VPCs

### Debugging Commands

```bash
# Validate Terraform configuration
terraform validate

# Format Terraform files
terraform fmt -recursive

# Show specific resource details
terraform state show <resource_name>

# View detailed logs
TF_LOG=DEBUG terraform apply

# Check AWS resources
aws elb describe-load-balancers
aws ec2 describe-instances
aws ec2 describe-security-groups
```

## 🎓 Best Practices

### 1. State Management
```hcl
# Use remote state in production (S3 + DynamoDB)
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

### 2. Variable Organization
```bash
# Use .tfvars files for different environments
terraform apply -var-file="prod.tfvars"
terraform apply -var-file="dev.tfvars"
```

### 3. Security Groups
```hcl
# Use descriptive names and descriptions
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for Application Load Balancer"
}
```

### 4. Health Checks
```hcl
health_check {
  healthy_threshold   = 2
  unhealthy_threshold = 2
  timeout             = 3
  interval            = 30
  path                = "/"
  matcher             = "200"
}
```

### 5. Tagging Strategy
```hcl
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    CreatedAt   = timestamp()
  }
}
```

### 6. Documentation
- Document all variables in `variables.tf`
- Add comments explaining complex configurations
- Maintain this README with updates
- Keep a changelog for infrastructure changes

### 7. Version Control
```bash
# Ignore sensitive files
echo "terraform.tfstate*" >> .gitignore
echo "*.tfvars" >> .gitignore
echo ".terraform/" >> .gitignore
```





