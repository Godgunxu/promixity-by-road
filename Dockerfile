# Use Python 3.9.6 as base
FROM python:3.9.6

# Set working directory
WORKDIR /app

# Copy and install Python dependencies
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Install MinIO client
RUN apt-get update && apt-get install -y curl && \
    curl -o /usr/bin/mc https://dl.min.io/client/mc/release/linux-amd64/mc && \
    chmod +x /usr/bin/mc

# Copy all necessary scripts
COPY 1_dist_time_to_nearest_destination_with_admin_area.py /app/
COPY run_with_minio.sh /app/
COPY preprocess_upload.sh /app/
COPY merge_chunks.sh /app/

# Make all shell scripts executable
RUN chmod +x /app/*.sh

# Set default entrypoint (for processing one chunk per pod)
ENTRYPOINT ["/bin/bash", "/app/run_with_minio.sh"]