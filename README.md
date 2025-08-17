# 📘 Prometheus Installation on Ubuntu (Production)

## 1. Create Prometheus User
```bash
sudo useradd --no-create-home --shell /bin/false prometheus
```

## 2. Create Required Directories
```bash
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus
```

## 3. Download Prometheus (Official Release)
```bash
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v3.5.0/prometheus-3.5.0.linux-amd64.tar.gz
tar xvf prometheus-3.5.0.linux-amd64.tar.gz
cd prometheus-3.5.0.linux-amd64
```

## 4. Install Binaries
```bash
sudo cp prometheus /usr/local/bin/
sudo cp promtool /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool
```

## 5. Configure Prometheus
Copy the configuration file:
```bash
sudo cp prometheus.yml /etc/prometheus/
sudo chown -R prometheus:prometheus /etc/prometheus
```

## 6. Create Systemd Service
```bash
sudo nano /etc/systemd/system/prometheus.service
```

Add the following:
```ini
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \\
  --config.file=/etc/prometheus/prometheus.yml \\
  --storage.tsdb.path=/var/lib/prometheus

[Install]
WantedBy=multi-user.target
```

## 7. Start and Enable Prometheus
```bash
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus
```

## 8. Verify Service
```bash
systemctl status prometheus
```

## 9. Access Prometheus Web UI
Open in browser:
```
http://<server-ip>:9090
```

---

## 📌 Notes for Production
- Open port `9090` only for trusted networks (via UFW, iptables, or cloud Security Groups).
- Run Prometheus behind **reverse proxy** (Nginx/HAProxy) if exposed to internet.
- Backup `/var/lib/prometheus` regularly (contains metrics data).
- Use **system monitoring** + Prometheus alert rules for self-monitoring.
