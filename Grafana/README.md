# 📘 Grafana Installation on Ubuntu

## 1. Create Grafana User

```bash
sudo useradd --no-create-home --shell /bin/false grafana
```

## 2. Create Grafana Directories

```bash
sudo mkdir /etc/grafana
sudo mkdir /var/lib/grafana
sudo chown grafana:grafana /var/lib/grafana
```

## 3. Download Grafana

```bash
cd /tmp
wget https://dl.grafana.com/oss/release/grafana-10.6.0.linux-amd64.tar.gz
tar -xvf grafana-10.6.0.linux-amd64.tar.gz
cd grafana-10.6.0
```

## 4. Install Grafana Binaries

```bash
sudo cp bin/grafana-server /usr/local/bin/
sudo cp bin/grafana-cli /usr/local/bin/
sudo chown grafana:grafana /usr/local/bin/grafana-server
sudo chown grafana:grafana /usr/local/bin/grafana-cli
```

## 5. Configure Grafana

```bash
sudo cp conf/defaults.ini /etc/grafana/grafana.ini
sudo chown -R grafana:grafana /etc/grafana
```

## 6. Create Grafana Systemd Service

```bash
sudo nano /etc/systemd/system/grafana.service
```

Add:

```ini
[Unit]
Description=Grafana
Wants=network-online.target
After=network-online.target

[Service]
User=grafana
Group=grafana
Type=simple
ExecStart=/usr/local/bin/grafana-server \
  --config=/etc/grafana/grafana.ini \
  --homepath=/tmp/grafana-10.6.0

[Install]
WantedBy=multi-user.target
```

## 7. Start and Enable Grafana

```bash
sudo systemctl daemon-reload
sudo systemctl enable grafana
sudo systemctl start grafana
```

## 8. Verify Grafana

```bash
systemctl status grafana
```

## 9. Access Grafana Web UI

```
http://<server-ip>:3000
```

* Default login: `admin` / `admin`
* Change password on first login.

---

## 📌 Notes for Production

* Open port `3000` only for trusted networks.
* Run Grafana behind reverse proxy (Nginx/HAProxy) if exposed to internet.
* Backup `/var/lib/grafana` regularly.
* Enable HTTPS for secure access.
* Configure Prometheus as a data source in Grafana for metrics visualization.
