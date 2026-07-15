#!/bin/bash
dnf update -y
dnf install -y docker
systemctl enable --now docker
usermod -aG docker ec2-user

curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

mkdir -p /opt/monitoring
cat > /opt/monitoring/prometheus.yml << 'PROMEOF'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "app"
    ec2_sd_configs:
      - region: ${aws_region}
        port: 8000
        filters:
          - name: "tag:Name"
            values: ["url-shortener-dev-app"]
    relabel_configs:
      - source_labels: [__meta_ec2_private_ip]
        target_label: __address__
        replacement: "$${1}:8000"

  - job_name: "node-exporter"
    static_configs:
      - targets: ["localhost:9100"]

  - job_name: "cadvisor"
    static_configs:
      - targets: ["localhost:8080"]
PROMEOF

cat > /opt/monitoring/docker-compose.yml << 'COMPOSEEOF'
services:
  node-exporter:
    image: prom/node-exporter:latest
    network_mode: host
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /sys:/sys:ro
      - /var/lib/docker:/var/lib/docker:ro
    network_mode: host
  prometheus:
    image: prom/prometheus:latest
    volumes:
      - /opt/monitoring/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus
    network_mode: host
  grafana:
    image: grafana/grafana:latest
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana
    network_mode: host
volumes:
  prometheus_data:
  grafana_data:
COMPOSEEOF

cd /opt/monitoring
/usr/local/bin/docker-compose up -d