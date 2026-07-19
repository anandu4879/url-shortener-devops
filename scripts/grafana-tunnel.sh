#!/bin/bash
# scripts/grafana-tunnel.sh
INSTANCE_ID=$(cd terraform/environments/dev && terraform output -raw monitoring_instance_id)
echo "Tunneling to Grafana on $INSTANCE_ID..."
aws ssm start-session \
  --target "$INSTANCE_ID" \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["3000"],"localPortNumber":["3000"]}' \
  --profile url-shortener-devops