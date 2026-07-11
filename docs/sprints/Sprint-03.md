# Sprint 3 — AWS Networking Fundamentals

## Objective

Build a strong understanding of AWS networking concepts before implementing them with Terraform.

This sprint focuses on **why** networking components exist, how they interact, and how they are used to build secure, scalable, and highly available cloud architectures.

---

# Topics Covered

* Virtual Private Cloud (VPC)
* CIDR Blocks
* Public & Private Subnets
* Internet Gateway
* NAT Gateway
* Route Tables
* Security Groups
* Network ACLs
* Multi-AZ Design
* High Availability
* Network Isolation

---

# Learning Objectives

By the end of this sprint I should be able to explain:

* Why every AWS architecture starts with a VPC
* How CIDR addressing works
* Why public and private subnets exist
* Why applications belong in private subnets
* Why databases should never be publicly accessible
* How private instances reach the Internet
* The difference between Internet Gateway and NAT Gateway
* How Route Tables determine traffic flow
* Differences between Security Groups and Network ACLs

---

# Planned Network Architecture

```
                        Internet
                            │
                    Internet Gateway
                            │
                    Public Route Table
                            │
          ┌─────────────────┴─────────────────┐
          │                                   │
 Public Subnet (AZ-A)                 Public Subnet (AZ-B)

      ALB                             NAT Gateway
                                         │
                                         │
                                 Private Route Table
                                         │
          ┌─────────────────┴─────────────────┐
          │                                   │
 Private Subnet (AZ-A)               Private Subnet (AZ-B)

     FastAPI App                     FastAPI App
          │                                   │
          └──────────────┬────────────────────┘
                         │
                     PostgreSQL
```

---

# Architecture Decisions

## Custom VPC

### Decision

Create a custom VPC instead of using the AWS Default VPC.

### Why?

* Full control over networking
* Better security
* Demonstrates networking knowledge
* Industry best practice

### Alternative

Default VPC

### Trade-off

Requires additional planning but provides significantly greater flexibility and security.

---

## CIDR Block

### Decision

```
10.0.0.0/16
```

### Why?

Provides enough address space for future expansion without needing to redesign the network.

### Lessons

* CIDR ranges are difficult to resize later.
* Plan generously from the beginning.

---

## Public & Private Subnets

### Public Subnets

Purpose

* Application Load Balancer
* NAT Gateway

Characteristics

* Route to Internet Gateway
* Internet accessible (when Security Groups allow)

---

### Private Subnets

Purpose

* EC2 Application Servers
* Amazon RDS

Characteristics

* No direct Internet access
* Only reachable through internal AWS networking

---

## Multi-AZ Deployment

Two Availability Zones will be used.

Why?

* High Availability
* Fault Tolerance
* Better AWS Architecture
* AWS Well-Architected Framework recommendation

---

# Internet Gateway

## Purpose

Allows resources inside public subnets to communicate with the Internet.

### Key Learning

Attaching an Internet Gateway to a VPC does **not** automatically make every subnet public.

A subnet only becomes public when its Route Table points to the Internet Gateway.

---

# NAT Gateway

## Purpose

Allows resources inside private subnets to initiate outbound Internet connections while preventing inbound Internet access.

Examples

* Pull Docker images
* Install packages
* Download application dependencies

### Alternative

NAT Instance

### Why NAT Gateway?

* Managed by AWS
* Higher availability
* Less operational overhead

Trade-off

Higher cost than a NAT Instance.

---

# Route Tables

Route Tables determine where network traffic should go.

## Public Route Table

```
0.0.0.0/0 → Internet Gateway
```

---

## Private Route Table

```
0.0.0.0/0 → NAT Gateway
```

Key takeaway:

A subnet is considered public or private entirely because of its Route Table.

---

# Security Groups

Security Groups act as virtual firewalls attached to AWS resources.

Characteristics

* Stateful
* Resource-level
* Allow rules only

Planned Security Groups

## ALB Security Group

Allow

* HTTP (80)
* HTTPS (443)

Source

```
0.0.0.0/0
```

---

## Application Security Group

Allow

Application Port

Source

ALB Security Group

---

## Database Security Group

Allow

PostgreSQL (5432)

Source

Application Security Group

---

# Network ACLs

Network ACLs provide subnet-level traffic filtering.

Characteristics

* Stateless
* Ordered Rules
* Allow and Deny rules

Decision

Use AWS default Network ACLs and rely primarily on Security Groups for this project.

Reason

Simpler management and aligns with project scale.

---

# AWS Resources Planned

Sprint 4 and Sprint 5 will implement:

* 1 Custom VPC
* 2 Public Subnets
* 2 Private Subnets
* 1 Internet Gateway
* 1 NAT Gateway
* Elastic IP
* Public Route Table
* Private Route Table
* Route Table Associations
* Security Groups

---

# Commands

No implementation commands during this sprint.

This sprint focused entirely on networking concepts and architecture planning.

---

# Interview Questions

* What is a VPC?
* Why use a custom VPC instead of the default VPC?
* What is CIDR notation?
* Why use a /16 VPC?
* What makes a subnet public?
* What makes a subnet private?
* Why deploy across multiple Availability Zones?
* Why can't private instances access the Internet directly?
* NAT Gateway vs NAT Instance?
* Internet Gateway vs NAT Gateway?
* Security Group vs Network ACL?
* Stateful vs Stateless?
* Why reference Security Groups instead of CIDR blocks?

---

# AWS SAA Concepts

This sprint directly covers major AWS Solutions Architect Associate topics:

* VPC Design
* High Availability
* Multi-AZ Architecture
* Route Tables
* CIDR Planning
* Internet Gateway
* NAT Gateway
* Security Groups
* Network ACLs

---

# Screenshots

Capture after Sprint 5 deployment:

* AWS VPC Console
* Public Subnets
* Private Subnets
* Route Tables
* Internet Gateway
* NAT Gateway
* Elastic IP
* Security Groups
* VPC Resource Map

---

# Lessons Learned

* Networking is the foundation of every AWS architecture.
* Public and private subnets are defined by Route Tables.
* NAT Gateway enables outbound Internet access without exposing private resources.
* Multi-AZ architecture improves resilience.
* Security Groups provide resource-level security, while Network ACLs protect at the subnet level.
* Careful CIDR planning avoids costly redesigns later.

---

# Next Sprint

Sprint 4 — Terraform Fundamentals

Topics:

* Terraform Providers
* State
* Remote Backend
* Modules
* Variables
* Outputs
* Data Sources
* Infrastructure as Code

By the end of Sprint 4, the architecture designed in this sprint will be provisioned using Terraform.
