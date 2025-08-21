# ilo-exporter-hp
Imran's ILO Exporter for HP servers

# iLO Exporter

iLO Exporter is a simple Flask-based API that executes a shell script (`ilo_exporter.sh`) 
to query hardware metrics (via SNMP/iLO) and exposes them in a Prometheus-compatible format.
**This iLO Exporter is designed to work with HP servers, providing seamless monitoring and metrics integration.**

## 🚀 Features
- Disk health status
- Disk temperature
- Smart storage values
- Power supply status
- RAID status
- Prometheus `/metrics` endpoint

## 📂 Project Structure
```
ilo-exporter/
├── app/
│ ├── main.py # Flask API exposing /metrics
│ ├── requirements.txt # Python dependencies
│ ├── ilo_exporter.sh # Script to fetch iLO metrics
├── Grafana/
│ ├── dashboard.json # Flask API exposing /metrics
├── Dockerfile # Container build file
└── README.md # Project documentation
```


## 🔧 Requirements
- Python 3.12+
- Flask
- SNMP utilities (`snmp`, `snmptrapd`)
- ipmitool (if needed)

If running in Docker, these are already installed.

## Run Locally (without Docker)
#### Install Python deps:
    apt install snmp snmptrapd
    pip install -r app/requirements.txt

#### Start the app:
    python app/main.py

#### Test:
    curl "http://localhost:8000/metrics?host=hostname"

## 🐳 Running with Docker
#### Build:
    docker build -t ilo-exporter .

#### Run (recommended: host networking for SNMP reachability):
    docker run -d --name ilo-exporter --network host -p 8000:8000 ilo-exporter

#### Test:
    curl "http://localhost:8000/metrics?host=hostname"

## Prometheus Configuration
Example job (scraping exporter at 192.168.1.2:8000 for iLO host 192.168.1.23 ). Add to prometheus.yml:
    scrape_configs:
      - job_name: 'host_192.168.1.23'
        metrics_path: '/metrics'
        params:
          host: ['192.168.1.23']
        static_configs:
          - targets: ['192.168.1.2:8000']
            labels:
              instance: '192.168.1.2'


## Grafana Dashboard
Import the provided dashboard:
- File: Grafana/dashboard.json
- In Grafana: Dashboards → Import → Upload JSON → select your Prometheus datasource → Import

<img width="652" height="420" alt="image" src="https://github.com/user-attachments/assets/86fee58b-2c86-4415-a0b4-252bec497590" />
<img width="1114" height="434" alt="image" src="https://github.com/user-attachments/assets/902adb7f-b492-4417-8134-be3261f1ccd9" />




The dashboard includes panels for:
- Disk health
- Disk temperature
- Smart storage values
- Power supply status
- RAID status

## Notes & Tips
- If SNMP MIBs aren’t loading in the container, ensure `/etc/snmp/snmp.conf` contains:
      mibs +ALL
- If your script calls external tools (snmpwalk, ssh, curl, ipmitool), ensure they’re installed in the image (the Dockerfile should apt-get install them).
- Use `--network host` so the 

