#!/bin/bash
dnf update -y
dnf install -y docker
systemctl enable --now docker
usermod -aG docker ec2-user

# Placeholder — real app image pull happens once ECR exists in Sprint 6/7
docker run -d --name placeholder -p 8000:8000 \
  python:3.11-slim python -m http.server 8000