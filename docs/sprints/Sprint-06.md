# Sprint 6 — Application Development

## Objective

Replace the placeholder web server with a production-style FastAPI application that implements URL shortening, Redis caching, PostgreSQL persistence, health checks, and container deployment.

This sprint focuses on application architecture, clean code organization, caching strategies, database integration, and preparing the application for deployment on AWS.

---

# Why This Sprint Matters

Until now we have built the infrastructure.

This sprint finally gives that infrastructure something meaningful to run.

Instead of focusing on complex business logic, the application is intentionally simple so that the focus remains on:

- Cloud Architecture
- Infrastructure
- Scalability
- Reliability
- Observability
- DevOps Practices

---

# Application Overview

The application provides three endpoints.

## POST /shorten

Creates a shortened URL.

Example

```
POST /shorten
```

Returns

```
{
    "short_code": "Ab3XyZ",
    "short_url": "/Ab3XyZ"
}
```

---

## GET /{code}

Redirects users to the original URL.

Example

```
GET /Ab3XyZ
```

Flow

```
Client

↓

Redis

↓

(Cache Miss)

↓

PostgreSQL

↓

Redis Cache

↓

Redirect
```

---

## GET /health

Health endpoint used by:

- Application Load Balancer
- Auto Scaling Group
- Monitoring

The endpoint verifies:

- Application
- PostgreSQL connectivity
- Redis availability

---

# Technology Stack

Backend

- Python
- FastAPI

Database

- PostgreSQL

Cache

- Redis

ORM

- SQLAlchemy

Validation

- Pydantic

Container

- Docker

Image Registry

- Amazon ECR

---

# Project Structure

```
app/

├── src/
│   ├── main.py
│   ├── database.py
│   ├── models.py
│   ├── schemas.py
│   ├── cache.py
│   └── shortcode.py
│
├── requirements.txt
├── Dockerfile
└── .dockerignore
```

---

# Architecture

```
             Client
                │
                ▼
           FastAPI API
                │
      ┌─────────┴─────────┐
      │                   │
      ▼                   ▼
   PostgreSQL         Redis Cache
```

---

# Design Decisions

## FastAPI

### Why FastAPI?

- High Performance
- Automatic API Documentation
- Async Support
- Built-in Validation
- Easy Dependency Injection

### Alternatives

- Flask
- Django
- Express.js
- Go

Decision

FastAPI provides modern development practices while remaining lightweight.

---

# URL Generation Strategy

## Decision

Generate random Base62 strings.

Example

```
aB3Xd9
```

---

## Why?

Advantages

- Difficult to guess
- Does not expose database growth
- Simple implementation

---

## Alternatives

### Auto Increment

Pros

- No collisions

Cons

- Predictable
- Easy enumeration

---

### Hashing URLs

Pros

- Deterministic

Cons

- Collision handling
- Harder to manage

---

Decision

Random Base62 strings with collision detection.

---

# Database

Database

```
PostgreSQL
```

Table

```
url_mappings
```

Columns

- ID
- Short Code
- Original URL
- Click Count
- Created Time

The Short Code column is indexed to improve lookup performance.

---

# Redis Caching

Caching Strategy

```
Cache Aside
```

Request Flow

```
User Request

↓

Redis

↓

Cache Hit?

YES → Redirect

NO

↓

PostgreSQL

↓

Store in Redis

↓

Redirect
```

---

# Why Cache Aside?

Advantages

- Reduces database load
- Faster redirects
- Simple architecture
- Easy recovery

If Redis becomes unavailable:

- Application continues working
- Reads fall back to PostgreSQL

Redis improves performance but is never treated as a critical dependency.

---

# Database Connection

Database connections are managed through SQLAlchemy.

Features

- Connection Pooling
- Automatic Reconnection
- Retry Logic
- Dependency Injection

Connection retries allow the application to wait for PostgreSQL during startup instead of crashing immediately.

---

# Environment Variables

Following Twelve-Factor App principles, configuration is injected through environment variables.

Examples

```
DATABASE_URL

REDIS_URL

PYTHONUNBUFFERED
```

Benefits

- Same Docker image across environments
- No hardcoded credentials
- Easy deployment
- Stateless application

---

# Docker

Application is containerized using Docker.

Current image contains:

- FastAPI
- SQLAlchemy
- Redis Client
- PostgreSQL Driver

Application runs entirely inside a container.

---

# Docker Compose

Local development environment includes:

- FastAPI
- PostgreSQL
- Redis

Docker networking allows containers to communicate using service names rather than IP addresses.

---

# Amazon ECR

Docker images are stored inside Amazon Elastic Container Registry.

Repository Settings

- Immutable Image Tags
- Scan On Push

Benefits

- Secure image storage
- Vulnerability scanning
- Versioned deployments

---

# Security

Current security practices:

- Environment Variables
- Non-root Containers
- Immutable Images
- IAM Authentication for ECR Pulls

Future improvements:

- AWS Parameter Store
- Secrets Manager
- Database Credential Rotation

---

# Application Flow

```
Client

↓

POST /shorten

↓

Generate Random Code

↓

Collision Check

↓

PostgreSQL

↓

Return Short URL
```

Redirect Flow

```
GET /abc123

↓

Redis

↓

Cache Hit?

YES

↓

Redirect

NO

↓

PostgreSQL

↓

Update Cache

↓

Redirect
```

---

# Terraform Changes

New infrastructure introduced

- Amazon ECR Repository

Existing EC2 instances now:

- Pull Docker image from ECR
- Authenticate using IAM Role

No Docker credentials are stored inside the instance.

---

# AWS Services Used

- Amazon EC2
- Amazon ECR
- Amazon RDS
- IAM
- Systems Manager
- VPC
- Security Groups

---

# AWS SAA Concepts Covered

- Stateless Applications
- Environment Variables
- Managed Databases
- Caching
- Amazon ECR
- IAM Roles
- Container Deployments

---

# Screenshots

Capture after deployment

## Local

- Docker Compose Running
- FastAPI Swagger UI
- Redis Container
- PostgreSQL Container

---

## AWS

- Amazon ECR Repository
- Docker Image
- Scan Results
- EC2 Pulling Image
- Running Application

---

## Application

- POST /shorten
- Redirect Working
- Health Endpoint
- PostgreSQL Table
- Redis Keys

---

# Lessons Learned

- FastAPI enables rapid API development with built-in validation.
- Redis significantly reduces database reads through cache-aside caching.
- Environment variables make the application portable across environments.
- Connection retry logic improves startup reliability.
- Docker networking eliminates hardcoded IP addresses.
- Amazon ECR provides secure image storage with vulnerability scanning.
- Application code should remain stateless to support Auto Scaling.

---

# Interview Questions

- Why choose FastAPI over Flask?
- Why avoid sequential short URLs?
- What is Base62 encoding?
- How does cache-aside caching work?
- What happens when Redis is unavailable?
- Why use environment variables instead of configuration files?
- Why implement database connection retries?
- What does SQLAlchemy's connection pooling provide?
- Why enable immutable tags in Amazon ECR?
- Why should Docker images be environment agnostic?
- Why are stateless applications important for Auto Scaling?
- What improvements would be required before deploying this application to production?

---

# Cost Summary

| Resource | Estimated Cost |
|----------|----------------|
| Amazon ECR | Minimal (pay only for image storage) |
| Docker Images | Negligible |
| Redis & PostgreSQL | Already provisioned in previous sprint |

No significant additional AWS costs were introduced in this sprint.

---

# Next Sprint

## Sprint 7 — CI/CD Pipeline

Next sprint will automate the complete deployment process using GitHub Actions.

Topics include:

- Continuous Integration
- Automated Testing
- Docker Image Build
- Amazon ECR Push
- Terraform Validation
- Infrastructure Deployment
- Security Scanning
- Continuous Delivery