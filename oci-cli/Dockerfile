# Use slim Python base
FROM python:3.11-slim

# Install OS tools (optional: curl/unzip if needed for troubleshooting)
RUN apt-get update && apt-get install -y curl unzip && \
    rm -rf /var/lib/apt/lists/*

# Install the latest OCI CLI from PyPI
RUN pip install --no-cache-dir --upgrade oci-cli

# Set default command
ENTRYPOINT ["oci"]

