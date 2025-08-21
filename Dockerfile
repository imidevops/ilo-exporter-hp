# Use slim Python image
FROM python:3.12-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# Copy and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app files
COPY app/ .

# Ensure script is executable
RUN chmod +x ilo_exporter.sh


# Install dependencies required for ilo_exporter.sh
RUN apt-get update && apt-get install -y --no-install-recommends \
    snmp snmptrapd
# Expose the port Flask uses
EXPOSE 8000

# Run the app
CMD ["python", "main.py"]
