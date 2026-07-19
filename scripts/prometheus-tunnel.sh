#!/bin/bash
# scripts/prometheus-tunnel.sh
INSTANCE_ID=$(cd terraform/environments/dev && terraform output -raw monitoring_instance_id)
echo "Tunneling to Prometheus on $INSTANCE_ID..."
aws ssm start-session \
  --target "$INSTANCE_ID" \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["9090"],"localPortNumber":["9090"]}' \
  --profile url-shortener-devops