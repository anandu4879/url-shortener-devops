# Sprint 7 — Continuous Integration & Continuous Deployment (CI/CD)

## Objective

Automate the complete software delivery process using GitHub Actions, from code commit to application deployment on AWS.

This sprint focuses on building a production-inspired CI/CD pipeline that validates application changes, builds Docker images, scans for vulnerabilities, updates infrastructure, deploys the application, verifies deployment health, and prepares rollback capabilities.

---

# Why This Sprint Matters

Manual deployments are slow, repetitive, and error-prone.

During previous sprints several deployment issues were encountered:

- Docker architecture mismatch (ARM vs AMD64)
- Immutable Docker tag conflicts
- Route ordering bugs
- Manual deployment verification

CI/CD automates these repetitive tasks and ensures every deployment follows the exact same validated process.

---

# Topics Covered

- Continuous Integration
- Continuous Deployment
- GitHub Actions
- OpenID Connect (OIDC)
- IAM Federation
- Amazon ECR
- Docker Image Scanning
- Terraform Automation
- Manual Approval Gates
- Deployment Health Checks
- Rollback Strategy

---

# CI/CD Pipeline Overview

```
Developer

      │
      ▼

Git Push

      │
      ▼

GitHub Actions

      │
      ▼

Test

      │
      ▼

Lint

      │
      ▼

Docker Build

      │
      ▼

Security Scan

      │
      ▼

Push to Amazon ECR

      │
      ▼

Terraform Plan

      │
      ▼

Manual Approval

      │
      ▼

Terraform Apply

      │
      ▼

Health Check

      │
      ▼

Production
```

---

# Pipeline Stages

## 1. Testing

Purpose

Validate application functionality before building Docker images.

Tools

- pytest

Benefits

- Detects logic errors early
- Prevents broken code from being deployed

---

## 2. Code Quality

Static code analysis is performed before deployment.

Tool

- flake8

Benefits

- Consistent coding standards
- Early error detection
- Improved maintainability

---

## 3. Docker Build

Docker images are built automatically.

Key Configuration

```
--platform linux/amd64
```

Why?

The application is deployed to Amazon EC2 instances using AMD64 architecture.

Explicitly specifying the platform prevents architecture mismatch issues during deployment.

---

## 4. Security Scanning

Every Docker image is scanned before being pushed.

Tool

- Trivy

Checks

- High severity vulnerabilities
- Critical vulnerabilities

Pipeline behavior

If vulnerabilities exceed the defined threshold, the deployment stops automatically.

---

## 5. Push to Amazon ECR

Docker images are stored inside Amazon Elastic Container Registry.

Image Tags

Instead of manually maintaining versions such as:

```
v1
v2
v3
```

the pipeline automatically tags images using the Git commit SHA.

Example

```
84d5abf1
```

Benefits

- Immutable versioning
- Complete deployment traceability
- Easy rollback

---

## 6. Terraform Plan

Infrastructure changes are reviewed before deployment.

Command

```bash
terraform plan
```

Benefits

- Preview infrastructure modifications
- Prevent accidental changes
- Safer deployments

---

## 7. Manual Approval

Before infrastructure changes are applied, GitHub Environments require manual approval.

Why?

Production deployments should never happen without human review.

This provides an additional safety layer before modifying live infrastructure.

---

## 8. Terraform Apply

After approval, infrastructure changes are applied automatically.

Command

```bash
terraform apply
```

This updates the running environment with the newly built application image.

---

## 9. Health Check

Deployment success is verified automatically.

Health checks confirm:

- EC2 instance is running
- Application is reachable
- Target Group reports healthy targets
- Load Balancer routing works correctly

If deployment fails, the pipeline exits with an error.

---

# Authentication

## OpenID Connect (OIDC)

The pipeline authenticates to AWS using GitHub's OpenID Connect integration.

Instead of storing long-lived AWS credentials as GitHub Secrets:

```
AWS_ACCESS_KEY_ID

AWS_SECRET_ACCESS_KEY
```

GitHub requests temporary credentials directly from AWS.

Benefits

- No long-lived credentials
- Improved security
- Automatic credential rotation
- Least privilege access

---

# IAM Design

Two IAM Roles exist.

## EC2 Role

Permissions

- Read images from Amazon ECR
- Access AWS Systems Manager

Purpose

Application runtime.

---

## GitHub Actions Role

Permissions

- Push Docker images
- Execute Terraform
- Access Amazon ECR

Purpose

Deployment automation.

Keeping these responsibilities separate follows the Principle of Least Privilege.

---

# GitHub Actions Workflow

The workflow executes automatically whenever code is pushed to the main branch.

Workflow stages

```
Push

↓

Test

↓

Lint

↓

Build

↓

Scan

↓

Push

↓

Terraform Plan

↓

Manual Approval

↓

Terraform Apply

↓

Health Check
```

---

# Docker Image Versioning

Each deployment produces a unique Docker image.

Example

```
url-shortener:84d5abf1
```

Benefits

- No overwritten images
- Easier debugging
- Repeatable deployments
- Reliable rollback

---

# Rollback Strategy

If deployment verification fails:

- Previous image tag can be redeployed
- Infrastructure remains unchanged
- Deployment history remains traceable

Future improvements include automatic rollback based on deployment health.

---

# Repository Structure

```
.github/

└── workflows/

    └── ci-cd.yml
```

---

# Secrets Used

Current GitHub Secrets

- DB_PASSWORD
- TARGET_GROUP_ARN

AWS authentication uses OIDC and therefore does not require AWS access keys.

---

# AWS Services Used

- GitHub Actions
- IAM
- OpenID Connect
- Amazon ECR
- Amazon EC2
- Elastic Load Balancer
- Auto Scaling Group
- Terraform

---

# AWS SAA Concepts Covered

- Infrastructure Automation
- IAM Federation
- Least Privilege
- Immutable Infrastructure
- Deployment Automation
- Amazon ECR
- Health Checks

---

# Screenshots

Capture the following after implementation.

## GitHub

- Successful Workflow Run
- Workflow Graph
- Manual Approval
- Build Logs
- Trivy Scan Results

---

## AWS

- Amazon ECR Repository
- Docker Images
- EC2 Running Updated Image
- Target Group Health
- Load Balancer

---

## Terraform

- Terraform Plan
- Terraform Apply

---

# Lessons Learned

- Automation eliminates repetitive deployment tasks.
- CI catches application issues before deployment.
- CD ensures consistent deployments.
- Docker images should use immutable tags.
- Security scanning should block vulnerable deployments.
- OIDC removes the need for long-lived AWS credentials.
- Deployment health verification increases reliability.
- Infrastructure changes should always be reviewed before execution.

---

# Interview Questions

- What is the difference between CI and CD?
- Why use GitHub Actions instead of Jenkins?
- Why authenticate using OIDC instead of AWS Access Keys?
- What problem does immutable image tagging solve?
- Why should Terraform Plan and Apply be separate stages?
- Why introduce a manual approval step?
- Why perform vulnerability scanning before deployment?
- How does a deployment health check improve reliability?
- What is the purpose of GitHub Environments?
- How would you implement automatic rollback?

---

# Cost Summary

| Resource | Estimated Cost |
|----------|----------------|
| GitHub Actions | Free for this project scale |
| Amazon ECR | Existing cost |
| EC2 Infrastructure | Existing cost |
| Additional AWS Cost | Negligible |

No significant AWS costs were introduced during this sprint.

---

# Next Sprint

## Sprint 8 — Monitoring & Observability

The next sprint focuses on implementing a complete monitoring stack using:

- Prometheus
- Grafana
- Node Exporter
- cAdvisor
- Application Metrics
- Infrastructure Metrics
- Docker Metrics
- Alerting
- Dashboards

This will provide complete visibility into application performance, system health, and infrastructure utilization.