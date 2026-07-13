# Production-Ready URL Shortener on AWS

> A production-inspired DevOps project built while preparing for AWS Solutions Architect Associate (SAA-C03) and DevOps Engineer roles.

![Project Status](https://img.shields.io/badge/Status-In%20Progress-blue)
![AWS](https://img.shields.io/badge/AWS-SAA-orange)
![Terraform](https://img.shields.io/badge/Terraform-IaC-623CE4)
![Docker](https://img.shields.io/badge/Docker-Containerized-2496ED)
![Monitoring](https://img.shields.io/badge/Monitoring-Prometheus%20%2B%20Grafana-E6522C)

---

# Overview

This repository documents my journey of building a production-style cloud application from scratch while preparing for AWS Solutions Architect Associate and DevOps Engineer interviews.

Instead of focusing on complex business logic, this project focuses on building real-world infrastructure and operational practices including:

- Infrastructure as Code
- Cloud Networking
- CI/CD
- Monitoring & Observability
- Security
- Cost Optimization
- Production Readiness

The application itself is intentionally simple so that the majority of effort goes into infrastructure engineering.

---

# Architecture

```
Internet
      │
      ▼
Internet Gateway
      │
┌─────┴──────────┐
│                │
Public AZ-A   Public AZ-B
│                │
ALB         NAT Gateway
                  │
          Private Route Table
                  │
      ┌───────────┴───────────┐
      │                       │
Private AZ-A             Private AZ-B
      │                       │
  FastAPI                FastAPI
      │
      ▼
 PostgreSQL

Monitoring
 ├── Prometheus
 ├── Grafana
 ├── Node Exporter
 └── cAdvisor
```

---

# Technology Stack

## Cloud

- AWS EC2
- Amazon RDS
- VPC
- Public & Private Subnets
- Internet Gateway
- NAT Gateway
- Route Tables
- Security Groups
- Application Load Balancer
- Auto Scaling Group
- IAM
- CloudWatch
- S3

## Infrastructure as Code

- Terraform

## Containerization

- Docker
- Docker Compose

## Backend

- Python
- FastAPI
- PostgreSQL
- Redis
- Nginx

## CI/CD

- GitHub Actions

## Monitoring

- Prometheus
- Grafana
- Node Exporter
- cAdvisor

---

# Repository Structure

```text
.
├── app/
├── terraform/
|     │
|     ├── bootstrap/
|     │   └── main.tf
|     │
|     ├── environments/
|     │   └── dev/
|     │       ├── backend.tf
|     │       ├── main.tf
|    │       ├── variables.tf
|     │       └── outputs.tf
|     │
|     └── modules/
|     └── vpc/
|          ├── main.tf
|          ├── variables.tf
|          └── outputs.tf
|
├── monitoring/
├── nginx/
├── docs/
├── .github/
├── docker-compose.yml
└── README.md
```

---

# Sprint Progress

| Sprint | Topic | Status |
|---------|-------|--------|
| Sprint 0 | Planning | ✅ |
| Sprint 1 | Git & Repository Structure | ✅ |
| Sprint 2 | Docker | ✅ |
| Sprint 3 | Networking | ✅ |
| Sprint 4 | Terraform | ✅ |
| Sprint 5 | AWS Infrastructure | ✅ |
| Sprint 6 | Application | ✅ |
| Sprint 7 | CI/CD | ⏳ |
| Sprint 8 | Monitoring | ⏳ |
| Sprint 9 | Security | ⏳ |
| Sprint 10 | Optimization | ⏳ |
| Sprint 11 | Production Readiness | ⏳ |
| Sprint 12 | Documentation | ⏳ |

---

# Current Features

- Project planning completed
- Professional repository structure
- Trunk-based Git workflow
- Conventional Commits
- Multi-stage Docker build
- Docker Compose development environment
- FastAPI placeholder service
- PostgreSQL container
- Redis container
- Docker health checks
- Non-root container
- Docker bridge networking
## Current Features

- ✅ Production project planning
- ✅ Git repository with trunk-based workflow
- ✅ Conventional Commits
- ✅ Dockerized FastAPI application
- ✅ Multi-stage Docker builds
- ✅ Docker Compose local development
- ✅ PostgreSQL container
- ✅ Redis container
- ✅ Docker bridge networking
- ✅ Health checks
- ✅ Custom AWS networking architecture
- ✅ Multi-AZ VPC design
- ✅ Terraform Infrastructure as Code
- ✅ Modular Terraform architecture
- ✅ Remote Terraform state (S3)
- ✅ Terraform state locking (DynamoDB)

---

# Local Development

```bash
docker compose up --build
```

Run in background

```bash
docker compose up -d
```

View running containers

```bash
docker compose ps
```

View logs

```bash
docker compose logs -f app
```

Stop

```bash
docker compose down
```

Destroy everything

```bash
docker compose down -v
```

---


# Screenshots


---



# Future Improvements

- ECS Deployment
- Kubernetes Migration
- Blue/Green Deployment
- OpenTelemetry
- Loki
- Tempo
- AWS WAF
- CloudFront
- Multi-Region Deployment

---

# Current Cost

Current AWS Spend

```
$0.00
```

No cloud resources have been provisioned yet.

---

# Infrastructure as Code

Infrastructure is provisioned using **Terraform**.

### Implemented

- Modular Terraform architecture
- AWS Provider
- Variables
- Outputs
- Modules
- Remote Backend
- State Locking
- Availability Zone Discovery
- VPC Module
- Security Groups
- Route Tables

### Terraform Commands

```bash
terraform init

terraform fmt

terraform validate

terraform plan

terraform apply

terraform destroy
```

# Security

Implemented

- Least-Privilege Security Groups
- Application isolation
- Multi-tier networking
- Remote Terraform state
- Encrypted S3 backend
- DynamoDB state locking

Upcoming

- IAM Roles
- GitHub OIDC
- AWS Systems Manager
- Secrets Management