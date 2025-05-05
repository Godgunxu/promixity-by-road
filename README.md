# 📍 Proximity-by-Road (OpenShift Parallel Processing)

> ✍️ **Original Python script by Brian Kelsey**  
> 📧 Contact: Brian.Kelsey@gov.bc.ca  
> ⚙️ Maintained by [@Godgunxu](https://github.com/Godgunxu)

This project calculates the **nearest facility** to each address using Euclidean distance followed by real-world drive time via the BC Route Planner API.

It supports **parallelized execution in OpenShift** using indexed jobs and MinIO for distributed storage.

---

## 🚀 Features

- ✅ Splits large address CSVs into chunks
- ✅ Each chunk processed in parallel OpenShift Job Pods
- ✅ Euclidean filter + real road distance lookup
- ✅ Results uploaded to MinIO (per chunk)
- ✅ Merges final output to one CSV
- ✅ Fully Dockerized and CI/CD friendly

---

## 📂 Project Structure

```bash
.
├── [1_dist_time_to_nearest_destination_with_admin_area.py](http://_vscodecontentref_/1)  # Core logic
├── [run_with_minio.sh](http://_vscodecontentref_/2)              # Script run by each OpenShift Job pod
├── [preprocess_upload.sh](http://_vscodecontentref_/3)           # Splits & uploads CSV chunks to MinIO
├── [merge_chunks.sh](http://_vscodecontentref_/4)                # Merges output chunks into final CSV
├── Dockerfile                     # Container definition
├── [proximity-job.yaml](http://_vscodecontentref_/5)             # OpenShift Indexed Job definition
├── [requirements.txt](http://_vscodecontentref_/6)               # Python requirements
├── [README.md](http://_vscodecontentref_/7)                      # Project documentation
````

⸻

🧪 Preprocessing (Split & Upload)

chmod +x preprocess_upload.sh
./preprocess_upload.sh site_Hybrid_geocoder.csv 20

	•	🔹 Splits into 20 even chunks
	•	🔹 Uploads to: myminio/proximity-input/chunks/

⸻

☁️ OpenShift Job Deployment

1. Build & Push Image

oc new-build --name=proximity-analysis --binary --strategy=docker
oc start-build proximity-analysis --from-dir=. --follow

2. Create Secret

# minio-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: minio-secret
type: Opaque
stringData:
  MINIO_ENDPOINT: minio-data-integration-datastore-api.apps.silver.devops.gov.bc.ca
  MINIO_ACCESS_KEY: routerdata
  MINIO_SECRET_KEY: routerdata@gov.bc.ca
  BC_API_KEY: <your_bc_api_key>

oc apply -f minio-secret.yaml

3. Launch Parallel Job

Edit completions in proximity-job.yaml to match chunk count and parallelism to your desired pod concurrency:

oc apply -f proximity-job.yaml

To re-run:

oc delete job proximity-analysis-job --ignore-not-found
oc apply -f proximity-job.yaml



⸻

🧩 Merging Final Output

After all jobs complete, merge all partial results:

chmod +x merge_chunks.sh
./merge_chunks.sh

	•	🔹 Downloads all from proximity-output/chunks/
	•	🔹 Merges into final_result_<timestamp>.csv
	•	🔹 Uploads to proximity-output/

⸻

🔁 Automation Options
	•	🕒 Use an OpenShift CronJob to schedule regular runs
	•	🌐 Set up a MinIO webhook or use polling to trigger on new input
	•	🔧 Tekton pipeline integration (coming soon)

⸻

📦 Output Structure

Each pod writes to:

myminio/proximity-output/chunks/

Final merged result:

myminio/proximity-output/final_result_<timestamp>.csv



⸻

📬 Contact

Maintainer: @Godgunxu
Original Script: Brian Kelsey – 📧 Brian.Kelsey@gov.bc.ca
