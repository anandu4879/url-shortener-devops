# Sprint 0 — Planning

## Objective

Plan the project before writing any infrastructure or application code.

---

## Project

Production-ready URL Shortener with Click Analytics.

---

## Why This Project?

The business logic is intentionally simple so that the focus remains on cloud architecture, automation, networking, security, monitoring, and CI/CD.

---

## Technology Decisions

### Backend

- Python
- FastAPI

Why?

- Simple
- Modern
- Async support
- Automatic API documentation

Alternatives

- Flask
- Express
- Go
- Spring Boot

---

### Database

PostgreSQL

Why?

- Durable storage
- ACID compliance

---

### Cache

Redis

Why?

- Extremely fast reads
- Demonstrates cache-aside architecture

---

## High-Level Architecture

- ALB
- EC2
- FastAPI
- Redis
- PostgreSQL
- Prometheus
- Grafana

---





## Lessons Learned

- Planning before implementation reduces mistakes.
- Infrastructure decisions should be justified before coding.
- Business logic should not distract from infrastructure learning.