#!/bin/bash
set -e

ADDR_FILE=$1           # e.g., site_Hybrid_geocoder.csv
NUM_CHUNKS=$2          # Total number of chunks you want
NUM_CHUNKS=20          # Total number of chunks you want
MINIO_ALIAS="myminio"

export MC_CONFIG_DIR=/tmp/.mc
export MC_TLS_SKIP_VERIFY=1

# ✅ Validate input
if [ -z "$ADDR_FILE" ] || [ -z "$NUM_CHUNKS" ]; then
  echo "❌ Usage: ./split_and_upload.sh <input_file.csv> <number_of_chunks>"
  exit 1
fi

echo "🔐 Setting up MinIO..."
mc alias set $MINIO_ALIAS https://minio-data-integration-datastore-api.apps.silver.devops.gov.bc.ca routerdata routerdata@gov.bc.ca

# ✅ Download input file
mkdir -p ./input
echo "⬇️ Downloading $ADDR_FILE..."
mc cp $MINIO_ALIAS/proximity-input/"$ADDR_FILE" ./input/

mkdir -p chunks
HEADER=$(head -n 1 ./input/"$ADDR_FILE")
TOTAL_LINES=$(($(wc -l < ./input/"$ADDR_FILE") - 1))
LINES_PER_CHUNK=$(( (TOTAL_LINES + NUM_CHUNKS - 1) / NUM_CHUNKS ))  # Ceiling division

echo "📊 Splitting $TOTAL_LINES rows into $NUM_CHUNKS chunks (~$LINES_PER_CHUNK lines each)..."

# ✅ Split and upload
tail -n +2 ./input/"$ADDR_FILE" | split -l $LINES_PER_CHUNK - chunks/tmp_chunk_

i=1
for file in chunks/tmp_chunk_*; do
  CHUNK_NAME=$(printf "chunk_%02d.csv" "$i")
  echo "$HEADER" > chunks/$CHUNK_NAME
  cat "$file" >> chunks/$CHUNK_NAME
  mc cp "chunks/$CHUNK_NAME" $MINIO_ALIAS/proximity-input/chunks/
  echo "✅ Uploaded $CHUNK_NAME"
  ((i++))
done