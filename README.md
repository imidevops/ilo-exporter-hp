# ilo-exporter-hp
Imran's ILO Exporter for HP servers

# iLO Exporter

iLO Exporter is a simple Flask-based API that executes a shell script (`ilo_exporter.sh`) 
to query hardware metrics (via SNMP/iLO) and exposes them in a Prometheus-compatible format.

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
├── Dockerfile # Container build file
└── README.md # Project documentation
```


## 🔧 Requirements
- Python 3.12+
- Flask
- SNMP utilities (`snmp`, `snmptrapd`)
- ipmitool (if needed)

If running in Docker, these are already installed.

## 🐳 Running with Docker

### Build the image
```bash
docker build -t ilo-exporter .
docker run -d --network host -p 8000:8000 ilo-exporter
```



