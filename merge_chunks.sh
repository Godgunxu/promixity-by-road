#!/bin/bash
set -e

WORKSPACE=/tmp/mergejob
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
FINAL_FILENAME="final_result_${TIMESTAMP}.csv"

export MC_CONFIG_DIR=/tmp/.mc
export MC_TLS_SKIP_VERIFY=1

mkdir -p "$WORKSPACE"
mc alias set myminio https://minio-data-integration-datastore-api.apps.silver.devops.gov.bc.ca routerdata routerdata@gov.bc.ca

echo "⬇️ Downloading all chunk outputs from proximity-output/chunks/"
mc cp --recursive myminio/proximity-output/chunks "$WORKSPACE/"

cd "$WORKSPACE/chunks"

echo "📦 Merging all chunk files into $FINAL_FILENAME..."
head -n 1 $(ls *.csv | head -n 1) > ../$FINAL_FILENAME

for f in *.csv; do
  tail -n +2 "$f" >> ../$FINAL_FILENAME
done

echo "⬆️ Uploading merged result to proximity-output/"
mc cp ../$FINAL_FILENAME myminio/proximity-output/

echo "✅ Final result uploaded as $FINAL_FILENAME"