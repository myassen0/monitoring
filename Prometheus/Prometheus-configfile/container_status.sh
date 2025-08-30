#!/bin/bash

# Path to Prometheus textfile collector output
OUTPUT="/var/lib/node_exporter/textfile_collector/container_status.prom"
TMP_OUTPUT=$(mktemp)

# -------------------------------
# Container status metrics
# -------------------------------
echo "# HELP container_status Container running status (1=running,0=exited,-1=paused,-2=dead,-3=other)" >> $TMP_OUTPUT
echo "# TYPE container_status gauge" >> $TMP_OUTPUT

# Loop over all containers
docker ps -a --format "{{.ID}};{{.Names}};{{.Status}}" | while IFS=";" read -r id name status
do
    # Determine numeric value
    case "$status" in
        Up*) value=1 ;;           # Running
        Exited*) value=0 ;;       # Exited normally
        "CrashLoop"*) value=-2 ;; # Example for crash-loop (adjust if using container restart policy)
        Paused*) value=-1 ;;      # Paused
        Dead*) value=-2 ;;        # Dead
        *) value=-3 ;;            # Other
    esac

    echo "container_status{container_id=\"$id\",container_name=\"$name\",status=\"$status\"} $value" >> $TMP_OUTPUT
done

# -------------------------------
# Container full info metrics
# -------------------------------
echo "# HELP container_info Docker container info" >> $TMP_OUTPUT
echo "# TYPE container_info gauge" >> $TMP_OUTPUT

docker ps -a --format "{{.ID}};{{.Names}};{{.Image}};{{.CreatedAt}};{{.Status}};{{.Ports}}" | while IFS=";" read -r id name image created status ports
do
    echo "container_info{container_id=\"$id\",container_name=\"$name\",image=\"$image\",created=\"$created\",status=\"$status\",ports=\"$ports\"} 1" >> $TMP_OUTPUT
done

# -------------------------------
# Replace old metrics file atomically
# -------------------------------
mv $TMP_OUTPUT $OUTPUT
chown nobody:nogroup $OUTPUT
chmod 644 $OUTPUT
