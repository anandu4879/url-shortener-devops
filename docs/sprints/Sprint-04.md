# Sprint 4 — Infrastructure as Code with Terraform

## Objective

Convert the network architecture designed in Sprint 3 into reusable, version-controlled Infrastructure as Code (IaC) using Terraform.

This sprint focuses on understanding Terraform fundamentals, building reusable modules, configuring remote state, and provisioning AWS networking resources in a repeatable and collaborative manner.

---

# Why Infrastructure as Code?

Before Terraform, cloud infrastructure was typically created manually through the AWS Console.

Although this works for small experiments, it quickly becomes difficult to:

- Reproduce environments
- Review infrastructure changes
- Track modifications
- Recover from failures
- Collaborate with teams

Terraform solves these problems by describing infrastructure as code.

---

# Why Terraform?

## Problem

Cloud infrastructure should be:

- Repeatable
- Version Controlled
- Reviewable
- Automated

Terraform provides all of these capabilities.

---

## Alternatives

| Tool | Description |
|-------|-------------|
| Terraform | Multi-cloud Infrastructure as Code |
| AWS CloudFormation | AWS native IaC |
| AWS CDK | Infrastructure using programming languages |
| Pulumi | IaC using Python, Go, TypeScript, etc. |

### Why Terraform?

For this project Terraform was selected because:

- Industry standard
- Cloud agnostic
- Excellent community support
- Highly demanded DevOps skill
- Declarative infrastructure model

---

# Terraform Concepts Learned

## Providers

Providers allow Terraform to communicate with external APIs.

Example:

- AWS
- Azure
- GCP
- GitHub

Our project uses:

- AWS Provider

---

## Resources

Resources represent actual cloud infrastructure.

Examples:

- aws_vpc
- aws_subnet
- aws_route_table
- aws_security_group
- aws_nat_gateway

---

## Variables

Variables make Terraform reusable.

Instead of hardcoding values like CIDR ranges or AWS Regions, variables allow different environments to reuse the same code.

---

## Outputs

Outputs expose useful information after deployment.

Examples:

- VPC ID
- Subnet IDs
- Security Group IDs

These outputs are later consumed by other Terraform modules.

---

## Modules

Modules are reusable collections of Terraform resources.

Instead of placing every AWS resource inside one large file, infrastructure is divided into logical components.

Example

```
modules/
    vpc/
```

Benefits

- Reusability
- Cleaner code
- Easier maintenance
- Better separation of concerns

---

## Remote Backend

Terraform stores infrastructure information inside a **State File**.

Instead of storing it locally, this project stores it in Amazon S3.

Benefits

- Team collaboration
- Centralized state
- Disaster recovery
- Version history

---

## State Locking

State locking prevents multiple users from modifying infrastructure simultaneously.

Implementation

- Amazon DynamoDB

Benefits

- Prevents state corruption
- Safe concurrent collaboration

---

## Data Sources

Terraform can read existing AWS resources without creating them.

Example

- Availability Zones

Instead of hardcoding AZ names, Terraform queries AWS dynamically.

---

## Locals

Locals simplify repeated values.

Example

- Resource naming
- Environment prefixes

---

## for_each vs count

### count

Creates resources using indexes.

```
Subnet 0
Subnet 1
Subnet 2
```

### for_each

Creates resources using meaningful keys.

```
us-east-1a

us-east-1b
```

Decision

Use **for_each** for subnet creation because it produces more stable infrastructure and avoids unnecessary recreation.

---

# Bootstrap Infrastructure

Terraform cannot use an S3 backend before the bucket exists.

To solve this problem, a separate bootstrap configuration creates:

- S3 Bucket
- DynamoDB Table

This bootstrap infrastructure is deployed once and remains available for the rest of the project.

---

# Infrastructure Created

The Terraform configuration provisions:

- Custom VPC
- Internet Gateway
- Public Subnets
- Private Subnets
- NAT Gateway
- Elastic IP
- Route Tables
- Route Table Associations
- Security Groups

---

# Security Group Design

The networking follows the principle of least privilege.

```
Internet
      │
      ▼
ALB Security Group
      │
      ▼
Application Security Group
      │
      ▼
Database Security Group
```

Communication is allowed only between the required tiers.

---

# Repository Structure

```
terraform/
│
├── bootstrap/
│   └── main.tf
│
├── environments/
│   └── dev/
│       ├── backend.tf
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── modules/
    └── vpc/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

# Terraform Workflow

```bash
terraform init

terraform fmt

terraform validate

terraform plan

terraform apply

terraform destroy
```

## Workflow Explanation

### terraform init

Downloads providers and initializes the backend.

---

### terraform fmt

Formats Terraform code according to official style guidelines.

---

### terraform validate

Checks configuration syntax.

---

### terraform plan

Displays infrastructure changes before deployment.

This is one of the most important Terraform commands because it prevents unintended modifications.

---

### terraform apply

Creates or updates infrastructure.

---

### terraform destroy

Deletes infrastructure.

The bootstrap backend (S3 + DynamoDB) is intentionally left intact.

---

# AWS Services Introduced

- Amazon VPC
- Amazon S3
- Amazon DynamoDB
- Internet Gateway
- NAT Gateway
- Route Tables
- Elastic IP
- Security Groups

---

# AWS SAA Concepts Covered

- Infrastructure as Code
- VPC Design
- Remote State
- Least Privilege
- Multi-AZ Architecture
- Security Groups
- Route Tables
- NAT Gateway
- Internet Gateway

---

# Screenshots

Capture the following after deployment:

- Terraform Plan Output
- Terraform Apply Success
- Terraform Graph (optional)
- AWS VPC Dashboard
- Public Subnets
- Private Subnets
- Route Tables
- Internet Gateway
- NAT Gateway
- Elastic IP
- Security Groups
- S3 Backend Bucket

---

# Lessons Learned

- Infrastructure should be managed as code.
- Terraform modules improve maintainability.
- Remote state enables safe collaboration.
- State locking prevents conflicting deployments.
- `terraform plan` should always be reviewed before `apply`.
- `for_each` is more stable than `count` for resources identified by unique keys.
- Separating bootstrap infrastructure from application infrastructure simplifies backend management.

---

# Interview Questions

- What is Infrastructure as Code?
- Why use Terraform over CloudFormation?
- What is Terraform State?
- Why is remote state important?
- Why use DynamoDB with Terraform?
- What is the difference between count and for_each?
- What are Terraform Modules?
- What is a Provider?
- What is a Data Source?
- Why should terraform plan always be reviewed?
- What problem does state locking solve?
- Why bootstrap the backend separately?

---

# Cost Summary

| Resource | Estimated Cost |
|----------|----------------|
| NAT Gateway | ~\$0.045/hour |
| Elastic IP | Minimal when attached |
| S3 Backend | Negligible |
| DynamoDB Lock Table | Negligible |

> **Recommendation:** Destroy all temporary infrastructure after capturing screenshots to avoid unnecessary NAT Gateway charges.

---

# Next Sprint

## Sprint 5 — AWS Infrastructure

Next sprint will deploy:

- EC2 Instances
- Application Load Balancer
- Auto Scaling Group
- Amazon RDS PostgreSQL
- IAM Roles
- AWS Systems Manager

The networking created in this sprint becomes the foundation for the application infrastructure.