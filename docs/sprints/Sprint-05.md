# Sprint 5 — AWS Infrastructure

## Objective

Deploy the application's compute and database infrastructure on AWS using the networking foundation created in Sprint 4.

This sprint focuses on provisioning production-style infrastructure including compute, load balancing, auto scaling, managed databases, IAM roles, and secure instance management.

---

# Why This Sprint Matters

Networking alone doesn't run an application.

This sprint introduces the infrastructure that actually hosts the application while following AWS Well-Architected best practices.

The final architecture includes:

- Application Load Balancer
- Auto Scaling Group
- EC2 Instances
- IAM Roles
- Systems Manager
- Amazon RDS PostgreSQL

---

# Topics Covered

- EC2
- Launch Templates
- Auto Scaling Groups
- Application Load Balancer
- Target Groups
- Listeners
- Amazon RDS
- IAM Roles
- IAM Instance Profiles
- AWS Systems Manager
- User Data
- Health Checks

---

# Final Infrastructure Architecture

```text
                     Internet
                          │
                          ▼
                Application Load Balancer
                          │
                Target Group (HTTP:8000)
                          │
          ┌───────────────┴───────────────┐
          │                               │
      EC2 Instance                    EC2 Instance
      (FastAPI)                       (FastAPI)
          │                               │
          └───────────────┬───────────────┘
                          │
                    Auto Scaling Group
                          │
                    IAM Instance Profile
                          │
                 AWS Systems Manager
                          │
                   Amazon RDS PostgreSQL
```

---

# Infrastructure Components

## Amazon EC2

### Purpose

Run the FastAPI application inside Docker containers.

### Why EC2?

- Full operating system control
- Docker support
- Matches AWS SAA objectives
- Foundation before learning ECS

### Alternatives

- ECS
- EKS
- AWS Lambda

### Decision

Use EC2 because it teaches infrastructure fundamentals before moving to managed container platforms.

---

## Launch Template

A Launch Template defines how new EC2 instances are created.

It contains:

- AMI
- Instance Type
- Security Groups
- IAM Instance Profile
- User Data
- Tags

### Why?

Instead of manually configuring every EC2 instance, Auto Scaling can launch identical instances automatically.

---

## Auto Scaling Group

### Purpose

Maintain application availability.

Configuration:

- Minimum Capacity: 1
- Desired Capacity: 1
- Maximum Capacity: 2

### Benefits

- Self-healing
- Automatic replacement of unhealthy instances
- Horizontal scaling

---

## Application Load Balancer

### Purpose

Distribute incoming HTTP requests across EC2 instances.

### Why ALB?

Application Load Balancer understands HTTP requests.

It supports:

- Host-based routing
- Path-based routing
- Health Checks
- HTTPS termination

---

## Target Group

The Target Group contains the EC2 instances serving application traffic.

Health Check:

```
Path:
/health
```

If an instance fails repeated health checks:

- ALB stops routing traffic.
- Auto Scaling replaces the unhealthy instance.

---

# IAM

## IAM Role

Instead of embedding AWS credentials inside EC2 instances, an IAM Role is attached.

Benefits:

- No Access Keys
- Temporary credentials
- Better security
- Least Privilege

---

## IAM Instance Profile

EC2 cannot directly attach IAM Roles.

AWS requires an Instance Profile that contains the IAM Role.

---

# AWS Systems Manager

Instead of opening SSH (Port 22), this project uses Systems Manager Session Manager.

Benefits:

- No SSH Keys
- No Bastion Host
- No Public SSH Access
- IAM Authentication
- Session Logging

---

# User Data

Every EC2 instance automatically executes a User Data script during its first boot.

Current responsibilities:

- Update packages
- Install Docker
- Enable Docker
- Start placeholder application

Later sprints will:

- Pull images from Amazon ECR
- Start production containers
- Configure monitoring agents

---

# Amazon RDS PostgreSQL

### Why RDS?

Instead of running PostgreSQL inside Docker on EC2:

AWS manages:

- Backups
- Maintenance
- Storage
- Failover
- Monitoring

---

## Configuration

Database Engine

```
PostgreSQL 16
```

Instance

```
db.t3.micro
```

Storage

```
20 GB GP3
```

Current decisions:

- Multi-AZ Disabled
- Public Access Disabled
- Deletion Protection Disabled
- Skip Final Snapshot Enabled

These settings minimize cost for a temporary learning environment.

---

# Security Architecture

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

Communication flow:

- Internet → ALB
- ALB → FastAPI
- FastAPI → PostgreSQL

No direct Internet access exists for EC2 or RDS.

---

# Terraform Modules

Current modules:

```
terraform/
└── modules/
    ├── vpc/
    ├── alb/
    ├── ec2/
    └── rds/
```

Each module has:

- main.tf
- variables.tf
- outputs.tf

Benefits:

- Reusable
- Maintainable
- Easier testing
- Cleaner architecture

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

Always review:

```bash
terraform plan
```

before applying infrastructure changes.

---

# AWS Services Used

- VPC
- EC2
- Auto Scaling
- Launch Templates
- Application Load Balancer
- Target Groups
- IAM
- Systems Manager
- Amazon RDS
- Security Groups

---

# AWS SAA Concepts Covered

- High Availability
- Auto Scaling
- Elastic Load Balancing
- IAM Roles
- Least Privilege
- Amazon RDS
- EC2
- Systems Manager
- Managed Databases
- Health Checks

---

## AWS Console

- EC2 Instances
- Auto Scaling Group
- Launch Template
- Application Load Balancer
- Target Group
- Target Health
- IAM Role
- Instance Profile
- Systems Manager Session
- Amazon RDS
- Security Groups

---

## Terraform

- terraform plan
- terraform apply
- terraform destroy

---

## Application

- ALB DNS Name
- Browser showing application
- Health endpoint

---

# Lessons Learned

- Auto Scaling improves application availability.
- Launch Templates standardize EC2 deployments.
- IAM Roles eliminate the need for static AWS credentials.
- Systems Manager is more secure than SSH.
- Application Load Balancer performs health checks and distributes traffic.
- Managed databases reduce operational overhead.
- Infrastructure should be modular and reusable.

---

# Interview Questions

- Why use an Auto Scaling Group instead of a single EC2 instance?
- What is the difference between a Launch Template and an EC2 instance?
- Why choose an Application Load Balancer over a Network Load Balancer?
- Why is Systems Manager preferred over SSH?
- What is an IAM Instance Profile?
- Why should EC2 use IAM Roles instead of Access Keys?
- What happens when an EC2 instance fails an ALB health check?
- Why deploy RDS inside private subnets?
- Why use Amazon RDS instead of self-managed PostgreSQL?
- What are the trade-offs of disabling Multi-AZ for RDS?

---

# Cost Summary

Approximate hourly cost while resources are running:

| Resource | Estimated Cost |
|----------|----------------|
| NAT Gateway | ~$0.045/hr |
| EC2 t3.micro | ~$0.010/hr |
| Application Load Balancer | ~$0.022/hr |
| Amazon RDS db.t3.micro | ~$0.016/hr |

**Estimated Total:** ~$0.09–0.10/hour

> Destroy all temporary resources after completing demonstrations and taking screenshots.

---

# Next Sprint

## Sprint 6 — Application Deployment

Next sprint will focus on:

- Building the complete FastAPI application
- PostgreSQL integration
- Redis caching
- URL shortening logic
- Click analytics
- Docker image creation
- Health endpoints
- Application metrics