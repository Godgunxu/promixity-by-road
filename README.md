# 📍 Proximity-by-Road

> ✍️ **Original Python script developed by Brian Kelsey**  
> 📧 Contact: Brian.Kelsey@gov.bc.ca

This project calculates the **nearest facility** to each input address using Euclidean distance and the BC Route Planner API for road travel time and distance.

It is designed to process large CSV datasets efficiently and can run locally or as a **Job in OpenShift**, pulling input data from **MinIO** and uploading results back.

---

## 🚀 Features

- ✅ Takes input CSVs (addresses + facilities)
- ✅ Calculates closest N facilities by Euclidean distance
- ✅ Gets real travel time via BC Route Planner API
- ✅ Uploads results to MinIO bucket
- ✅ Dockerized and ready for OpenShift Job deployment
- ✅ Supports re-running with environment variable overrides

---

## 📂 Project Structure

```
.
├── input/                               # Optional local input directory
├── 1_dist_time_to_nearest_destination_with_admin_area.py   # Main script
├── run_with_minio.sh                    # Wrapper script for OpenShift job
├── Dockerfile                           # Docker setup
├── proximity-job.yaml                   # OpenShift job definition
├── requirements.txt                     # Python dependencies
```

---

## 🧪 Local Run (with Docker)

1. **Build the Docker image:**

```bash
docker build -t proximity-analysis-local .
```

2. **Run the container with environment variables:**

```bash
docker run --rm \
  -e MINIO_ENDPOINT=your.minio.endpoint \
  -e MINIO_ACCESS_KEY=your-access-key \
  -e MINIO_SECRET_KEY=your-secret-key \
  -e BC_API_KEY=your-bc-api-key \
  proximity-analysis-local
```

---

## ☁️ OpenShift Job Deployment

1. **Apply the secret:**

```bash
oc apply -f minio-secret.yaml
```

2. **Start the job:**

```bash
oc apply -f proximity-job.yaml
```

3. **To re-run manually:**

```bash
oc delete job proximity-analysis-job --ignore-not-found
oc apply -f proximity-job.yaml
```

Or use a helper script like `rerun_job.sh`.

---

## 🔁 Automation Options

- Use a `CronJob` to schedule runs
- Poll MinIO or add webhook triggers to automate execution when new files arrive

---

## 🔐 Required Secrets

Create a secret named `minio-secret` in OpenShift with the following keys:

- `MINIO_ENDPOINT`
- `MINIO_ACCESS_KEY`
- `MINIO_SECRET_KEY`
- `BC_API_KEY`

---

## 📦 Output

Results are saved to:

```
proximity-output/<filename>_nearest_with_admin_id_<tag>_<timestamp>.csv
```

These are uploaded back to your MinIO bucket automatically after processing.

---

## 📬 Contact

Maintained by [@Godgunxu](https://github.com/Godgunxu)  
Script Author: Brian Kelsey – 📧 Brian.Kelsey@gov.bc.ca
