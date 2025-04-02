#!/bin/bash
set -e

echo "🚀 Starting proximity analysis job..."

# Set up writable config directory for mc
export MC_CONFIG_DIR=/tmp/.mc
export MC_TLS_SKIP_VERIFY=1

# Input arguments
WORKSPACE=$1
ADDR_FILE=$2
FID=$3
X_ADDR=$4
Y_ADDR=$5
ADMIN_ID=$6
FAC_FILE=$7
FAC_ID=$8
X_FAC=${9}
Y_FAC=${10}
PERCENT=${11}
EPSG=${12}
APIKEY=${13}
TAG=${14}

# Create input/output folders
mkdir -p "$WORKSPACE/input"
mkdir -p "$WORKSPACE/output"

echo "🔐 Setting up MinIO alias..."
mc alias set myminio https://$MINIO_ENDPOINT "$MINIO_ACCESS_KEY" "$MINIO_SECRET_KEY"

echo "📂 Listing files in 'proximity-input' bucket:"
mc ls myminio/proximity-input || echo "⚠️  Could not list bucket contents. Check credentials or bucket name."

#echo "⬇️  Downloading input files..."
#mc cp myminio/proximity-input/"$ADDR_FILE" "$WORKSPACE/input/"
#mc cp myminio/proximity-input/"$FAC_FILE" "$WORKSPACE/input/"

echo "⬇️  Downloading all files from 'proximity-input'..."
#mc cp --recursive myminio/proximity-input "$WORKSPACE/input/"
mc cp --recursive myminio/proximity-input "$WORKSPACE/input/"

# Move downloaded files out of subfolder to expected location
if [ -d "$WORKSPACE/input/proximity-input" ]; then
  mv "$WORKSPACE/input/proximity-input/"* "$WORKSPACE/input/"
  rmdir "$WORKSPACE/input/proximity-input"
fi
echo "⚙️  Running Python proximity analysis script..."

python /app/1_dist_time_to_nearest_destination_with_admin_area.py \
  "$WORKSPACE" "$ADDR_FILE" "$FID" "$X_ADDR" "$Y_ADDR" "$ADMIN_ID" \
  "$FAC_FILE" "$FAC_ID" "$X_FAC" "$Y_FAC" "$PERCENT" "$EPSG" "$APIKEY" "$TAG"

echo "📦 Locating output file..."
OUTPUT_FILE=$(ls "$WORKSPACE"/output/*_nearest_with_admin_id_*.csv | head -n 1)

echo "⬆️  Uploading result to MinIO..."
mc mb --ignore-existing myminio/proximity-output
mc cp "$OUTPUT_FILE" myminio/proximity-output/

echo "✅ Job complete! Output uploaded to 'proximity-output'."