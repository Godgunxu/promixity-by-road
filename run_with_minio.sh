#!/bin/bash
set -e

echo "🚀 Starting proximity analysis for assigned chunk..."

# Set up MinIO config
export MC_CONFIG_DIR=/tmp/.mc
export MC_TLS_SKIP_VERIFY=1

# Input arguments from OpenShift Job
WORKSPACE=$1
ORIGINAL_ADDR_FILE=$2
FID=$3
X_ADDR=$4
Y_ADDR=$5
ADMIN_ID=$6
FAC_FILE=$7
FAC_ID=$8
X_FAC=$9
Y_FAC=${10}
PERCENT=${11}
EPSG=${12}
APIKEY=${13}
TAG=${14}

# Create directories
mkdir -p "$WORKSPACE/input" "$WORKSPACE/output"

echo "🔐 Setting MinIO alias..."
mc alias set myminio https://$MINIO_ENDPOINT "$MINIO_ACCESS_KEY" "$MINIO_SECRET_KEY"

# 🔍 List chunk files from MinIO and get the Nth one based on JOB_INDEX
echo "📂 Fetching list of chunks from MinIO..."
CHUNK_LIST=$(mc ls myminio/proximity-input/chunks/ | awk '{print $NF}' | sort)

CHUNK_ARRAY=($CHUNK_LIST)
TOTAL_CHUNKS=${#CHUNK_ARRAY[@]}

# 🛑 Validate JOB_INDEX range
if [[ $JOB_INDEX -ge $TOTAL_CHUNKS ]]; then
  echo "❌ JOB_INDEX $JOB_INDEX out of range. Only $TOTAL_CHUNKS chunks found."
  exit 1
fi

ADDR_FILE=${CHUNK_ARRAY[$JOB_INDEX]}

echo "⬇️ Downloading input: $ADDR_FILE and $FAC_FILE..."
mc cp myminio/proximity-input/chunks/"$ADDR_FILE" "$WORKSPACE/input/" || { echo "❌ Failed to download $ADDR_FILE"; exit 1; }
mc cp myminio/proximity-input/"$FAC_FILE" "$WORKSPACE/input/" || { echo "❌ Failed to download $FAC_FILE"; exit 1; }

echo "⚙️ Running Python script on $ADDR_FILE..."
python /app/1_dist_time_to_nearest_destination_with_admin_area.py \
  "$WORKSPACE" "$ADDR_FILE" "$FID" "$X_ADDR" "$Y_ADDR" "$ADMIN_ID" \
  "$FAC_FILE" "$FAC_ID" "$X_FAC" "$Y_FAC" "$PERCENT" "$EPSG" "$APIKEY" "$TAG"

# Find output file
OUTPUT_FILE=$(ls "$WORKSPACE"/output/*_nearest_with_admin_id_*.csv | head -n 1)

if [[ -f "$OUTPUT_FILE" ]]; then
  echo "⬆️ Uploading result $OUTPUT_FILE to MinIO..."
  mc mb --ignore-existing myminio/proximity-output/chunks
  mc cp "$OUTPUT_FILE" myminio/proximity-output/chunks/
  echo "✅ Finished processing $ADDR_FILE"
else
  echo "❌ Output file not found. Processing may have failed."
  exit 1
fi