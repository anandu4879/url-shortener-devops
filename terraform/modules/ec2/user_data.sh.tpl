#!/bin/bash
dnf update -y
dnf install -y docker
systemctl enable --now docker
usermod -aG docker ec2-user

aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin ${ecr_repository_url}

docker run -d --name app -p 8000:8000 \
  -e DATABASE_URL="${database_url}" \
  -e REDIS_URL="${redis_url}" \
  ${ecr_repository_url}:v3