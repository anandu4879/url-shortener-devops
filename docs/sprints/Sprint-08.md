# Sprint 8 — Monitoring & Observability

## Objective

Implement a complete monitoring and observability stack to gain visibility into application performance, infrastructure health, container resource utilization, and system behavior.

This sprint introduces Prometheus, Grafana, Node Exporter, and cAdvisor, transforming the application from a "black box" into an observable production-style system.

---

# Why This Sprint Matters

A running application is not necessarily a healthy application.

Without monitoring:

- Performance issues go unnoticed.
- Resource exhaustion is difficult to diagnose.
- Cache performance cannot be measured.
- Infrastructure failures are detected only after users complain.

Monitoring provides visibility into both application behavior and infrastructure health.

---

# Topics Covered

- Monitoring vs Observability
- Prometheus
- Grafana
- Node Exporter
- cAdvisor
- Application Metrics
- Infrastructure Metrics
- Docker Metrics
- Prometheus Client Library
- Grafana Dashboards
- CloudWatch Integration

---

# Monitoring Architecture

```
                     Client
                        │
                        ▼
                 FastAPI Application
                        │
             /metrics Endpoint
                        │
                        ▼
                  Prometheus
                        │
        ┌───────────────┼───────────────┐
        │               │               │
        ▼               ▼               ▼
 Application      Node Exporter     cAdvisor
   Metrics         Host Metrics   Container Metrics
                        │
                        ▼
                   Grafana
                        │
                  Dashboards
```

---

# Why Monitoring?

Monitoring answers questions such as:

- Is the application healthy?
- Is response time increasing?
- Is Redis improving performance?
- Is CPU utilization approaching capacity?
- Is memory usage growing over time?
- Which container is consuming resources?

---

# Prometheus

## Purpose

Prometheus collects and stores time-series metrics.

Unlike traditional monitoring systems, Prometheus **pulls** metrics from applications at regular intervals.

Scrape Interval

```
15 seconds
```

---

## Why Prometheus?

Advantages

- Open Source
- Kubernetes Standard
- Powerful Query Language (PromQL)
- Portable Across Cloud Providers
- Excellent Grafana Integration

---

## Alternatives

- Amazon CloudWatch
- Datadog
- New Relic
- Zabbix

Decision

Prometheus provides cloud-independent monitoring skills while integrating seamlessly with Grafana.

---

# Grafana

## Purpose

Grafana visualizes Prometheus metrics through dashboards.

Benefits

- Interactive Dashboards
- Historical Trends
- Alerting
- Custom Panels
- Multiple Data Sources

---

# Prometheus vs CloudWatch

## Prometheus

Monitors:

- Application Metrics
- Custom Business Metrics
- Container Metrics

Examples

- Request Rate
- Request Latency
- Cache Hit Ratio
- URLs Created

---

## CloudWatch

Monitors AWS Infrastructure

Examples

- EC2 CPU Utilization
- ALB Request Count
- RDS Connections
- NAT Gateway Traffic
- EBS Throughput

---

## Why Both?

Prometheus and CloudWatch complement each other.

CloudWatch monitors AWS-managed infrastructure.

Prometheus monitors the application itself.

Both are required for complete observability.

---

# Application Metrics

The FastAPI application exposes metrics using:

```
/metrics
```

Metrics are collected through middleware, ensuring every request is automatically tracked.

---

## Request Counter

Measures

```
Total HTTP Requests
```

Labels

- HTTP Method
- Endpoint
- Status Code

---

## Request Latency

Measures

```
Request Duration
```

Metric Type

Histogram

Why Histogram?

Histograms enable percentile calculations such as:

- P50
- P95
- P99

Average latency alone often hides slow requests.

---

## Cache Metrics

Custom metrics

```
Cache Hits

Cache Misses
```

These metrics validate whether the Redis cache is improving application performance.

---

## URL Creation

Tracks

```
URLs Created
```

Useful for monitoring application usage over time.

---

# Metric Types

## Counter

Characteristics

- Only increases
- Never decreases

Examples

- Requests
- Cache Hits
- URLs Created

---

## Histogram

Characteristics

Stores observations inside buckets.

Examples

- Request Latency
- Database Query Duration

---

## Gauge

Characteristics

Can increase and decrease.

Examples

- Active Connections
- Current Memory Usage
- Current CPU Usage

---

# Middleware Instrumentation

FastAPI middleware automatically records metrics for every request.

Benefits

- No duplicate code
- Consistent monitoring
- Easy maintenance
- Future endpoints automatically monitored

---

# Node Exporter

Purpose

Collect operating system metrics.

Examples

- CPU Usage
- Memory Usage
- Disk Usage
- Network Throughput
- Filesystem Usage

Node Exporter monitors the host machine rather than the application.

---

# cAdvisor

Purpose

Monitor Docker containers.

Metrics

- CPU Usage
- Memory Usage
- Network Usage
- Filesystem Usage

Unlike Node Exporter, cAdvisor provides metrics for individual containers.

---

# Docker Compose

Monitoring stack now consists of:

```
FastAPI

PostgreSQL

Redis

Prometheus

Grafana

Node Exporter

cAdvisor
```

Every service communicates over the Docker bridge network.

---

# Persistent Volumes

Persistent storage is configured for:

Prometheus

```
prometheus_data
```

Grafana

```
grafana_data
```

Benefits

- Historical metrics survive container restarts.
- Dashboards remain intact.
- User accounts persist.

---

# Prometheus Configuration

Scrape Targets

- FastAPI Application
- Node Exporter
- cAdvisor

Configuration

```
scrape_interval: 15s
```

Docker networking allows Prometheus to reference services by container name rather than IP address.

---

# Grafana Dashboards

The following dashboards are planned.

## Application Dashboard

Metrics

- Request Rate
- Request Latency
- HTTP Status Codes
- URLs Created

---

## Cache Dashboard

Metrics

- Cache Hits
- Cache Misses
- Cache Hit Ratio

---

## Host Dashboard

Metrics

- CPU Usage
- Memory Usage
- Disk Usage
- Network Traffic

---

## Container Dashboard

Metrics

- CPU Usage Per Container
- Memory Usage Per Container
- Docker Network Usage
- Container Restarts

---

# Security Considerations

Current implementation exposes:

```
/metrics
```

without authentication.

Reason

Prometheus requires direct access for scraping.

Future improvement

Restrict access through:

- Security Groups
- Reverse Proxy Rules
- Internal Networking

---

# AWS Services Used

- Amazon EC2
- CloudWatch
- Application Load Balancer
- Amazon RDS

Open Source Components

- Prometheus
- Grafana
- Node Exporter
- cAdvisor

---

# AWS SAA Concepts Covered

- Amazon CloudWatch
- Infrastructure Monitoring
- Metrics
- Dashboards
- Alarms
- Health Checks
- Performance Monitoring

---

# Screenshots

Capture after implementation.

## Prometheus

- Targets Page
- Metrics Browser
- Successful Scrape Status

---

## Grafana

- Login Screen
- Data Source Configuration
- Application Dashboard
- Infrastructure Dashboard
- Cache Dashboard

---

## Docker

- Running Containers
- Docker Compose Services

---

## AWS

- CloudWatch Metrics
- EC2 Monitoring
- RDS Monitoring

---

# Lessons Learned

- Monitoring provides visibility into system behavior before failures occur.
- Prometheus collects application metrics through scraping.
- Grafana transforms raw metrics into meaningful dashboards.
- Middleware ensures every request is monitored consistently.
- Histograms are more useful than averages for latency analysis.
- Node Exporter and cAdvisor provide different layers of infrastructure visibility.
- CloudWatch and Prometheus solve different monitoring problems and are often used together.

---

# Interview Questions

- What is the difference between monitoring and observability?
- Why does Prometheus use a pull model?
- What is PromQL?
- Counter vs Gauge vs Histogram?
- Why use Histograms for latency?
- What does Node Exporter monitor?
- What does cAdvisor monitor?
- Why expose a `/metrics` endpoint?
- Why use middleware for instrumentation?
- Prometheus vs CloudWatch?
- Why use Grafana instead of Prometheus UI?
- What metrics would you monitor for a production API?

---

# Cost Summary

| Resource | Estimated Cost |
|----------|----------------|
| Prometheus | Runs on existing EC2 instance |
| Grafana | Runs on existing EC2 instance |
| Node Exporter | Negligible |
| cAdvisor | Negligible |

No additional AWS services were provisioned during this sprint.

---

# Production Considerations

Current implementation is optimized for learning.

A production deployment would include:

- Dedicated monitoring servers
- High Availability Prometheus
- Alertmanager
- Grafana Authentication
- Private `/metrics` endpoint
- Long-term metric storage
- CloudWatch Alarms
- Centralized logging

---

# Next Sprint

## Sprint 9 — Security Hardening

The next sprint focuses on securing the infrastructure and application.

Topics include:

- IAM Least Privilege
- GitHub OIDC
- AWS Systems Manager Parameter Store
- Secrets Management
- Security Hardening
- HTTPS
- TLS Certificates
- AWS WAF
- Network Security