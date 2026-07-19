#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

INSTANCE_ID=$(cd "$REPO_ROOT/terraform/environments/dev" && terraform output -raw monitoring_instance_id)

if [ -z "$INSTANCE_ID" ]; then
  echo "Error: could not get monitoring instance ID. Is the infrastructure applied?"
  exit 1
fi
echo "Tunneling to Prometheus on $INSTANCE_ID..."
aws ssm start-session \
  --target "$INSTANCE_ID" \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["9090"],"localPortNumber":["9090"]}' \
  --profile url-shortener-devops