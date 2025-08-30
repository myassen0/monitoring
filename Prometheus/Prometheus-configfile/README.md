# 📘 Prometheus Configuration Guide

This file explains the Prometheus configuration and alert rules used in your monitoring system, providing a complete overview for proper understanding.

---

## 1. Global Configuration

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
```

* **scrape\_interval**: The time interval between scraping all targets.
* **evaluation\_interval**: The time interval for evaluating alert rules.

---

## 2. Alerting Rules File

```yaml
rule_files:
  - "alert_rules.yml"
```

* Specifies the alert rules file containing all defined alerts.

---

## 3. Alertmanager Configuration

```yaml
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      - '192.168.1.101:9093' # Alertmanager IP and port
```

* Connects Prometheus to Alertmanager to send alerts.

---

## 4. Scrape Configurations

### 4.1 Prometheus Itself

```yaml
- job_name: 'prometheus'
  static_configs:
    - targets: ['192.168.1.101:9090']
      labels:
        environment: 'production'
        team: 'monitoring'
```

* Scrapes Prometheus itself to monitor internal performance.

### 4.2 Node Exporter

```yaml
- job_name: 'node_exporter'
  static_configs:
    - targets: ['192.168.1.102:9100', '192.168.1.100:9100', '192.168.1.101:9100']
      labels:
        environment: 'production'
        team: 'ops'
```

* **Description:**
  Node Exporter collects system metrics such as CPU, Memory, Disk, and Network usage from servers.
  Additionally, it reads metrics from the **Textfile Collector** at `/var/lib/node_exporter/textfile_collector`, where a custom script writes Docker container metrics.

* **Metrics Collected from the Script:**

  1. `container_status`: Numeric status of containers.

     * `1` = Running
     * `0` = Exited
     * `-1` = Paused
     * `-2` = Dead / CrashLoop
     * `-3` = Other
       Example: `container_status{container_id="abcd123",container_name="nginx",status="Up 3 hours"} 1`
  2. `container_info`: Detailed container metadata.

     * Fields include container ID, name, image, created time, status, and exposed ports.
       Example: `container_info{container_id="abcd123",container_name="nginx",image="nginx:latest",created="2025-08-30T14:12:00Z",status="Up 3 hours",ports="80/tcp"} 1`

* **Script Functionality:**

  1. Loops over all Docker containers and determines a numeric status value.
  2. Generates metrics for container status and full container info.
  3. Writes output atomically to the textfile collector directory.
  4. The script is scheduled via cron to run every minute for near real-time updates.

* **Cron Job Example:**

```bash
* * * * * /usr/local/bin/collect_container_metrics.sh
```

This setup allows Prometheus to monitor both host-level metrics and Docker container metrics through Node Exporter.

### 4.3 cAdvisor

```yaml
- job_name: 'cadvisor'
  scrape_interval: 15s
  static_configs:
    - targets: ['192.168.1.100:8081']
      labels:
        environment: 'production'
        team: 'ops'
```

* Monitors Docker containers (CPU, Memory, Network, Filesystem usage).

### 4.4 Oracle DB Exporter

```yaml
- job_name: 'oracle_db'
  static_configs:
    - targets: ['192.168.1.100:9161']
      labels:
        environment: 'production'
        team: 'dba'
```

* Monitors Oracle database (active sessions, tablespace usage, performance metrics).

### 4.5 Blackbox Exporter

```yaml
- job_name: 'blackbox'
  metrics_path: /probe
  params:
    module: [http_2xx]
  static_configs:
    - targets:
      - http://192.168.1.100:8080
      - http://192.168.1.100:9161
      - http://192.168.1.102:3000
      - http://192.168.1.101:9090
  relabel_configs:
    - source_labels: [__address__]
      target_label: __param_target
    - source_labels: [__param_target]
      target_label: instance
    - target_label: __address__
      replacement: 192.168.1.100:9115
```

* Checks service availability (HTTP 2xx) and collects response time metrics.

---

## 5. Alert Rules (alert\_rules.yml)

### 5.1 Predictive Alerts (CPU, Memory, Disk, Network)

* **CPU**: Alerts for trending high CPU usage.
* **Memory**: Alerts for trending high memory usage.
* **Disk**: Alerts for increasing disk usage.
* **Network**: Alerts for high latency or packet drops.

### 5.2 Oracle DB Alerts

* **High Sessions**: Alert when active sessions exceed threshold.
* **Tablespace Growth**: Alert when tablespace usage approaches critical level.

### 5.3 Container Alerts

* **Memory Trend**: Containers with high memory usage trend.
* **Frequent Restarts**: Containers restarting multiple times within a short period.

### 5.4 Container Status Alerts

* **High Memory Usage**: Container memory exceeds a certain threshold.
* **Container Down / Exited**: Containers that are stopped or unavailable.
* **Container Other State**: Containers in unexpected states.

Each alert contains:

* `expr`: PromQL expression defining the alert condition.
* `for`: Duration the condition must persist before firing the alert.
* `labels`: Additional metadata (e.g., severity).
* `annotations`: Alert description, summary, and detailed message.

---

## 6. Container Metrics via Node Exporter Textfile Collector

To monitor container states, a custom Bash script collects metrics from Docker and writes them to a textfile that Node Exporter reads.

#### Script Overview

* **Path:** `/var/lib/node_exporter/textfile_collector/container_status.prom`
* **Functionality:**

  1. Loops through all Docker containers.
  2. Generates a numeric status metric:

     * `1` = Running
     * `0` = Exited
     * `-1` = Paused
     * `-2` = Dead / CrashLoop
     * `-3` = Other
  3. Generates full container info metrics including ID, name, image, created time, status, and ports.
  4. Atomically replaces the old metrics file to ensure consistency.
* **Node Exporter:** Reads this textfile and exposes `container_status` and `container_info` metrics to Prometheus.

#### Cron Job

* The script is scheduled to run every minute:

```bash
* * * * * /usr/local/bin/collect_container_metrics.sh
```

This ensures near real-time updates of container status and info for Prometheus monitoring.

---

## 📌 Notes for Production

* Ensure all targets are correct and reachable.
* Monitor Prometheus performance to prevent overload.
* Use Alertmanager for reliable alert delivery.
* Regularly backup configuration and alert rule files.
* Connect Grafana for visualizing metrics and creating dashboards.
