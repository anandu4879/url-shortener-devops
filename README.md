# Production-Ready URL Shortener on AWS

> A production-inspired DevOps project built to demonstrate real-world cloud architecture, Infrastructure as Code, CI/CD, observability, and security best practices.

## Project Goal

This repository documents my journey of building a production-style URL Shortener from scratch while preparing for the AWS Solutions Architect – Associate certification and DevOps Engineer roles.

The goal is **not** to build the next Bitly.

The goal is to learn and demonstrate how modern applications are deployed, monitored, secured, and automated using AWS and DevOps practices.

Every infrastructure component will be created using Infrastructure as Code, documented, monitored, and destroyed after use to minimize cloud costs.

---

# Architecture (Final Target)

```
                Internet
                    │
                    ▼
         Application Load Balancer
                    │
      ┌─────────────┴─────────────┐
      │                           │
      ▼                           ▼
  EC2 Instance                EC2 Instance
 (Docker App)                (Docker App)
      │                           │
      └─────────────┬─────────────┘
                    │
             Private Network
                    │
        ┌───────────┴───────────┐
        ▼                       ▼
 PostgreSQL (RDS)          Redis Cache

                    │
              Monitoring Stack
        ┌───────────┴───────────┐
        ▼                       ▼
    Prometheus              Grafana

                    │
                 CloudWatch
```

---

# Technology Stack

## Cloud

* AWS VPC
* Public & Private Subnets
* Internet Gateway
* NAT Gateway
* Route Tables
* Security Groups
* EC2
* Auto Scaling Group
* Application Load Balancer
* Amazon RDS (PostgreSQL)
* Amazon ECR
* AWS Systems Manager
* CloudWatch
* IAM
* S3 (Terraform Backend)

---

## Application

* Python
* FastAPI
* PostgreSQL
* Redis
* Nginx

---

## DevOps

* Docker
* Docker Compose
* Terraform
* GitHub Actions

---

## Monitoring

* Prometheus
* Grafana
* Node Exporter
* cAdvisor

---

# Learning Objectives

Throughout this project I aim to understand:

* Infrastructure as Code with Terraform
* AWS networking fundamentals
* Docker and containerization
* CI/CD automation
* Secure IAM practices
* Monitoring and observability
* High availability architecture
* Cost optimization
* Scaling strategies
* Production troubleshooting

Rather than simply deploying services, every architectural decision will be documented with:

* Why the service exists
* Why it was selected
* Alternative approaches
* Trade-offs
* AWS Solutions Architect concepts
* Common interview questions

---

# Sprint Roadmap

* [x] Sprint 0 – Project Planning
* [x] Sprint 1 – Git & Repository Structure
* [x] Sprint 2 – Docker Fundamentals
* [ ] Sprint 3 – AWS Networking Concepts
* [ ] Sprint 4 – Terraform Infrastructure as Code
* [ ] Sprint 5 – AWS Infrastructure Deployment
* [ ] Sprint 6 – Application Development
* [ ] Sprint 7 – CI/CD Pipeline
* [ ] Sprint 8 – Monitoring & Observability
* [ ] Sprint 9 – Security Hardening
* [ ] Sprint 10 – Performance & Cost Optimization
* [ ] Sprint 11 – Production Readiness
* [ ] Sprint 12 – Documentation & Portfolio Packaging

---

# Repository Structure

```
.
├── app/
├── docker/
├── terraform/
│   ├── modules/
│   ├── environments/
│   └── backend/
├── monitoring/
│   ├── prometheus/
│   ├── grafana/
│   └── dashboards/
├── nginx/
├── scripts/
├── .github/
│   └── workflows/
├── docs/
└── README.md
```

---

# What Will Be Built

* URL shortening API
* Redirect service
* Click analytics
* Redis caching
* PostgreSQL persistence
* Dockerized application
* Infrastructure with Terraform
* Automated CI/CD pipeline
* Monitoring dashboards
* Production-style documentation

---

# Project Philosophy

This project is intentionally built like a real production system rather than a tutorial.

The focus is on:

* understanding *why* each technology exists,
* making architecture decisions,
* documenting trade-offs,
* and building practical skills expected from DevOps engineers.

Every sprint concludes with:

* Learning summary
* Architecture decisions
* Interview questions
* LinkedIn update
* GitHub commit history
* Screenshot checklist
* Cost summary
* Infrastructure cleanup steps

---

# Current Status


# Planned Monitoring

The monitoring stack will include:

* Prometheus
* Grafana
* Node Exporter
* cAdvisor
* FastAPI application metrics
* Docker metrics
* EC2 system metrics
* PostgreSQL metrics
* Redis metrics

Sample dashboards will include:

* CPU Usage
* Memory Usage
* Disk Usage
* Network Throughput
* HTTP Requests
* Response Time
* Error Rate
* Cache Hit Ratio
* Database Connections
* Container Resource Usage

---

# Cost Management

Since this project is intended for learning and portfolio development:

* Infrastructure will only run during lab sessions.
* All AWS resources will be destroyed after demonstrations.
* Terraform will manage both provisioning and cleanup.
* Screenshots and documentation will be captured before teardown.

---

# Future Enhancements

* ECS deployment
* Kubernetes migration
* Blue/Green deployments
* Canary releases
* AWS WAF
* CloudFront
* ElastiCache
* OpenTelemetry
* Loki
* Tempo
* Multi-region deployment
* Disaster recovery

---

# Why This Project?

Most portfolio projects demonstrate application development.

This project demonstrates infrastructure engineering.

The application is intentionally simple so the focus remains on:

* AWS architecture
* DevOps workflows
* Automation
* Monitoring
* Security
* Scalability
* Reliability

These are the skills expected of modern DevOps and Cloud Engineers.

---

# License

This repository is intended for educational and portfolio purposes.
