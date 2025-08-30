# 📘 Alertmanager Configuration Guide

This README explains the Alertmanager configuration used for sending notifications, specifically for Telegram integration.

---

## 1. Global Configuration

```yaml
global:
  resolve_timeout: 5m
```

* **resolve\_timeout**: Maximum time to wait for an alert to be considered resolved after it stops firing.

---

## 2. Routing Configuration

```yaml
route:
  group_by: ['alertname']
  group_wait: 1s
  group_interval: 1s
  repeat_interval: 5m
  receiver: 'telegram-notifications'
```

* **group\_by**: Alerts are grouped by the `alertname` label.
* **group\_wait**: Time to wait before sending the first notification of a new group (1 second).
* **group\_interval**: Minimum interval between two notifications for the same group (1 second).
* **repeat\_interval**: Minimum time before a resolved alert can be re-sent (5 minutes).
* **receiver**: Default receiver for the alerts (`telegram-notifications`).

---

## 3. Receivers Configuration

```yaml
receivers:
- name: 'telegram-notifications'
  telegram_configs:
  - bot_token: '<API>'
    chat_id: <ID>
    send_resolved: true
    parse_mode: 'HTML'
```

* **bot\_token**: Your Telegram bot API token.
* **chat\_id**: Chat ID where alerts will be sent.
* **send\_resolved**: Whether to send notifications when alerts are resolved.
* **parse\_mode**: HTML formatting is used in the messages.

---

## 4. Templates Configuration

```yaml
templates:
- '/etc/alertmanager/templates/telegram.tmpl'
```

* Points to the template file used to format alert messages for Telegram.

---

## 5. Telegram Template Example

The template `/etc/alertmanager/templates/telegram.tmpl` formats messages as follows:

```gotemplate
{{ define "telegram.default.message" }}
{{ if gt (len .Alerts.Firing) 0 }}
<b>🔥 FIRING: {{ .Alerts.Firing | len }} alert(s)</b>
{{ range .Alerts.Firing }}
---
<b>Alert:</b> {{ .Annotations.summary }}
<b>Severity:</b> {{ .Labels.severity }}
<b>Instance:</b> <code>{{ .Labels.instance }}</code>
{{ if .Annotations.description }}
<b>Details:</b> {{ .Annotations.description }}
{{ end }}
<a href="{{ .GeneratorURL }}">Graph</a>
{{ end }}
{{ end }}

{{ if gt (len .Alerts.Resolved) 0 }}
<b>✅ RESOLVED: {{ .Alerts.Resolved | len }} alert(s)</b>
{{ range .Alerts.Resolved }}
---
<b>Alert:</b> {{ .Annotations.summary }}
<b>Instance:</b> <code>{{ .Labels.instance }}</code>
{{ if .Annotations.description }}
<b>Details:</b> {{ .Annotations.description }}
{{ end }}
{{ end }}
{{ end }}
{{ end }}
```

* **Firing Alerts Section**: Displays all alerts currently firing with summary, severity, instance, details, and a link to the graph.
* **Resolved Alerts Section**: Displays all alerts that have been resolved with summary, instance, and details.

---

## 📌 Notes for Production

* Ensure the Telegram bot token and chat ID are correct.
* Adjust `group_wait`, `group_interval`, and `repeat_interval` to avoid spam while keeping alerts timely.
* Test template formatting with sample alerts to ensure messages appear correctly.
* Store templates in a consistent directory and maintain backups.
* Consider adding additional receivers (email, Slack, etc.) for redundancy.
