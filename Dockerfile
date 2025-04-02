# Matching python version to what was used on PC
FROM python:3.9.6

# Set working directory inside the container
WORKDIR /app

# Copy and install Python dependencies
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Download and install the MinIO client (mc) to /usr/bin
RUN apt-get update && apt-get install -y curl && \
    curl -o /usr/bin/mc https://dl.min.io/client/mc/release/linux-amd64/mc && \
    chmod +x /usr/bin/mc

# Copy your main Python script
COPY 1_dist_time_to_nearest_destination_with_admin_area.py /app/

# Copy the wrapper script and make it executable
COPY run_with_minio.sh /app/
RUN chmod +x /app/run_with_minio.sh

# Run the wrapper script with arguments from CMD
ENTRYPOINT ["/app/run_with_minio.sh"]