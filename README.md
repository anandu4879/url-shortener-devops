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
| Sprint 7 | CI/CD |✅ |
| Sprint 8 | Monitoring | ✅ |
---

## Current status
Sprints 0–9 complete and applied: planning, Git workflow, Docker,
networking, Terraform, AWS infrastructure, the application itself, CI/CD
with OIDC, full observability (Prometheus/Grafana/Alertmanager), and a
security hardening pass (Parameter Store secrets, IMDSv2, restricted
/metrics endpoint).

## Planned next (not yet built)
- **Optimization**: right-sizing instances based on real Grafana metrics,
  cache TTL tuning, target-tracking auto-scaling policy
- **Production readiness**: alert-to-notification wiring (Alertmanager →
  Slack/email), automated last-known-good rollback tracking
- **Documentation**: full architecture writeup, cost breakdown,
  lessons-learned doc, ECS/Kubernetes migration plan

These are scoped and understood conceptually (see design notes below) but
intentionally not built yet — prioritizing depth on the harder infra/CI/CD
work first.




