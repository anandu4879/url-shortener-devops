#!/bin/bash
dnf update -y
dnf install -y docker
systemctl enable --now docker
usermod -aG docker ec2-user

curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

mkdir -p /opt/monitoring
mkdir -p /opt/monitoring/grafana/provisioning/dashboards
mkdir -p /opt/monitoring/grafana/provisioning/datasources
mkdir -p /opt/monitoring/grafana/dashboards

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

cat > /opt/monitoring/grafana/provisioning/datasources/datasources.yml << 'DATASOURCEEOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://localhost:9090
    isDefault: true
DATASOURCEEOF

cat > /opt/monitoring/grafana/provisioning/dashboards/dashboards.yml << 'DASHPROVEOF'
apiVersion: 1

providers:
  - name: "default"
    folder: ""
    type: file
    updateIntervalSeconds: 30
    options:
      path: /etc/grafana/provisioning/dashboards
DASHPROVEOF

cat > /opt/monitoring/grafana/dashboards/url-shortener-overview.json << 'DASHJSONEOF'
{
  "title": "URL Shortener Overview",
  "timezone": "browser",
  "refresh": "15s",
  "panels": [
    {
      "id": 1,
      "title": "Request Rate",
      "type": "timeseries",
      "gridPos": { "h": 8, "w": 12, "x": 0, "y": 0 },
      "targets": [
        {
          "expr": "sum(rate(app_requests_total[5m])) by (endpoint)",
          "legendFormat": "{{endpoint}}"
        }
      ]
    },
    {
      "id": 2,
      "title": "P95 Latency",
      "type": "timeseries",
      "gridPos": { "h": 8, "w": 12, "x": 12, "y": 0 },
      "targets": [
        {
          "expr": "histogram_quantile(0.95, sum(rate(app_request_latency_seconds_bucket[5m])) by (le, endpoint))",
          "legendFormat": "{{endpoint}}"
        }
      ],
      "fieldConfig": {
        "defaults": { "unit": "s" }
      }
    },
    {
      "id": 3,
      "title": "Cache Hit Ratio",
      "type": "timeseries",
      "gridPos": { "h": 8, "w": 12, "x": 0, "y": 8 },
      "targets": [
        {
          "expr": "sum(rate(app_cache_hits_total[5m])) / (sum(rate(app_cache_hits_total[5m])) + sum(rate(app_cache_misses_total[5m])))",
          "legendFormat": "hit ratio"
        }
      ],
      "fieldConfig": {
        "defaults": { "unit": "percentunit", "min": 0, "max": 1 }
      }
    },
    {
      "id": 4,
      "title": "URLs Created (total)",
      "type": "stat",
      "gridPos": { "h": 8, "w": 6, "x": 12, "y": 8 },
      "targets": [
        { "expr": "app_urls_created_total" }
      ]
    },
    {
      "id": 5,
      "title": "App Container CPU",
      "type": "timeseries",
      "gridPos": { "h": 8, "w": 6, "x": 18, "y": 8 },
      "targets": [
        {
          "expr": "rate(container_cpu_usage_seconds_total{name=\"app\"}[5m])",
          "legendFormat": "app CPU"
        }
      ]
    },
    {
      "id": 6,
      "title": "Host CPU Usage",
      "type": "timeseries",
      "gridPos": { "h": 8, "w": 12, "x": 0, "y": 16 },
      "targets": [
        {
          "expr": "100 - (avg(rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
          "legendFormat": "CPU busy %"
        }
      ],
      "fieldConfig": {
        "defaults": { "unit": "percent" }
      }
    },
    {
      "id": 7,
      "title": "Host Memory Available",
      "type": "timeseries",
      "gridPos": { "h": 8, "w": 12, "x": 12, "y": 16 },
      "targets": [
        {
          "expr": "node_memory_MemAvailable_bytes",
          "legendFormat": "available"
        }
      ],
      "fieldConfig": {
        "defaults": { "unit": "bytes" }
      }
    }
  ]
}
DASHJSONEOF

cat > /opt/monitoring/docker-compose.yml << 'COMPOSEEOF'
services:
  node-exporter:
    image: prom/node-exporter:latest
    network_mode: host
    restart: unless-stopped
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /sys:/sys:ro
      - /var/lib/docker:/var/lib/docker:ro
    network_mode: host
    restart: unless-stopped
  prometheus:
    image: prom/prometheus:latest
    volumes:
      - /opt/monitoring/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus
    network_mode: host
    restart: unless-stopped
  grafana:
    image: grafana/grafana:latest
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana
      - /opt/monitoring/grafana/provisioning:/etc/grafana/provisioning:ro
      - /opt/monitoring/grafana/dashboards:/etc/grafana/provisioning/dashboards:ro
    network_mode: host
    restart: unless-stopped
volumes:
  prometheus_data:
  grafana_data:
COMPOSEEOF

cd /opt/monitoring
/usr/local/bin/docker-compose up -d