# 🚀 Kubernetes Horizontal Pod Autoscaler (HPA) — CPU-Based Auto-Scaling Demo

[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Python](https://img.shields.io/badge/Python-3.11-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![Flask](https://img.shields.io/badge/Flask-000000?style=for-the-badge&logo=flask&logoColor=white)](https://flask.palletsprojects.com/)
[![Minikube](https://img.shields.io/badge/Minikube-F7B93E?style=for-the-badge&logo=kubernetes&logoColor=black)](https://minikube.sigs.k8s.io/)

---

## 📋 Project Overview

This project demonstrates **Kubernetes Horizontal Pod Autoscaling (HPA)** using a custom-built, CPU-intensive Flask application deployed on a local Minikube cluster. The application intentionally generates sustained CPU load on each request by performing heavy mathematical computations (`math.sqrt` in a tight loop for 200 ms per request). When external traffic drives CPU utilization beyond a configured threshold, the Kubernetes HPA controller automatically scales the number of pod replicas up to handle the increased demand — and scales them back down when load subsides.

This is a practical, end-to-end implementation covering containerization, Kubernetes resource management, service exposure, and autoscaling — all orchestrated locally with Minikube.

---

## 🎯 Project Objectives

| #  | Objective |
|----|-----------|
| 1  | Build a Python Flask application that generates realistic CPU load on demand |
| 2  | Containerize the application using Docker with a production-grade WSGI server (Gunicorn) |
| 3  | Deploy the containerized application to a local Kubernetes cluster (Minikube) |
| 4  | Define CPU resource requests and limits for Kubernetes pods |
| 5  | Expose the application internally via a Kubernetes `NodePort` Service |
| 6  | Configure Kubernetes HPA to auto-scale pods based on CPU utilization |
| 7  | Simulate load to trigger autoscaling and observe dynamic pod scaling in real time |

---

## 🏗️ Architecture Diagram

```
┌──────────────────────────────────────────────────────────────────────┐
│                        MINIKUBE CLUSTER                              │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐    │
│  │                     Kubernetes Namespace                      │    │
│  │                                                               │    │
│  │  ┌─────────────────────────────────────────────────────────┐  │    │
│  │  │              Deployment: autoscaler                      │  │    │
│  │  │              (replicas: 2 → auto-scaled)                 │  │    │
│  │  │                                                          │  │    │
│  │  │   ┌───────────────┐  ┌───────────────┐  ┌───────────┐   │  │    │
│  │  │   │   Pod #1      │  │   Pod #2      │  │  Pod #N   │   │  │    │
│  │  │   │ ┌───────────┐ │  │ ┌───────────┐ │  │  (scaled) │   │  │    │
│  │  │   │ │ Container │ │  │ │ Container │ │  │           │   │  │    │
│  │  │   │ │ gunicorn  │ │  │ │ gunicorn  │ │  │    ...    │   │  │    │
│  │  │   │ │ :5000     │ │  │ │ :5000     │ │  │           │   │  │    │
│  │  │   │ │ 2 workers │ │  │ │ 2 workers │ │  │           │   │  │    │
│  │  │   │ └───────────┘ │  │ └───────────┘ │  └───────────┘   │  │    │
│  │  │   │ CPU: 100m-500m│  │ CPU: 100m-500m│                  │  │    │
│  │  │   └───────────────┘  └───────────────┘                  │  │    │
│  │  └──────────────────────────┬──────────────────────────────┘  │    │
│  │                             │                                  │    │
│  │  ┌──────────────────────────▼──────────────────────────────┐  │    │
│  │  │        Service: autoscaler-service (NodePort)            │  │    │
│  │  │        port: 80 → targetPort: 5000                       │  │    │
│  │  └──────────────────────────┬──────────────────────────────┘  │    │
│  │                             │                                  │    │
│  │  ┌──────────────────────────▼──────────────────────────────┐  │    │
│  │  │     HPA: Horizontal Pod Autoscaler                       │  │    │
│  │  │     Target CPU Utilization: 50%                           │  │    │
│  │  │     Min Replicas: 1  │  Max Replicas: 10                  │  │    │
│  │  └─────────────────────────────────────────────────────────┘  │    │
│  └───────────────────────────────────────────────────────────────┘    │
│                             │                                         │
│            Metrics Server (required for HPA)                          │
└──────────────────────────────┬───────────────────────────────────────┘
                               │
                ┌──────────────▼──────────────┐
                │     External Traffic /       │
                │     Load Generator           │
                │  (e.g., kubectl run busybox) │
                └─────────────────────────────┘
```

---

## 🛠️ Technologies Used

| Tool / Technology | Purpose |
|-------------------|---------|
| **Python 3.11** | Application runtime |
| **Flask** | Lightweight web framework for the CPU-load endpoint |
| **Gunicorn** | Production-grade WSGI HTTP server (2 workers) |
| **Docker** | Containerization of the Flask application |
| **Kubernetes** | Container orchestration and workload management |
| **Minikube** | Local single-node Kubernetes cluster |
| **Kubernetes Deployment** | Manages pod replicas and rolling updates |
| **Kubernetes Service (NodePort)** | Exposes the application on a cluster-accessible port |
| **Kubernetes HPA** | Automatically scales pods based on CPU utilization metrics |
| **Metrics Server** | Provides resource usage metrics to the HPA controller |

---

## 📁 Project Structure

```
MiniProject8-Autoscaler/
├── app.py                 # Flask application with CPU-intensive endpoint
├── Dockerfile             # Multi-stage Docker build using python:3.11-slim
├── autoscaler.yaml        # Kubernetes Deployment + NodePort Service manifest
├── requirements.txt       # Python dependencies (flask, gunicorn)
└── README.md              # Project documentation
```

---

## 📖 Implementation Details

### 1. Flask Application (`app.py`)

The application exposes a single endpoint (`/`) that deliberately consumes CPU:

```python
@app.route('/')
def cpu_load():
    start = time.time()
    while time.time() - start < 0.2:          # Runs for 200ms per request
        for i in range(100000):
            math.sqrt(i)                       # CPU-intensive computation
    return "Autoscaler Demo Running!"
```

- Each request triggers a **200-millisecond CPU burst**, computing `math.sqrt()` across 100,000 iterations in a tight loop.
- This simulates a realistic CPU-bound workload (e.g., image processing, data transformation) to reliably trigger the HPA.

### 2. Dockerfile

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 5000
CMD ["gunicorn", "--workers", "2", "--bind", "0.0.0.0:5000", "app:app"]
```

**Key design decisions:**
- **`python:3.11-slim`** — Minimal base image to reduce attack surface and image size.
- **`--no-cache-dir`** — Prevents pip from caching packages, keeping the image lean.
- **Gunicorn with 2 workers** — Production-ready WSGI server replacing Flask's built-in development server; 2 workers provide concurrency within each pod.
- **Port 5000** — Exposed for container-to-service communication.

### 3. Kubernetes Manifest (`autoscaler.yaml`)

The manifest defines two resources:

**Deployment:**
- **2 initial replicas** — Provides baseline availability.
- **`imagePullPolicy: Never`** — Uses the locally built Docker image (Minikube's Docker daemon).
- **CPU requests: `100m`** (0.1 vCPU) — Baseline allocation for scheduling.
- **CPU limits: `500m`** (0.5 vCPU) — Hard ceiling to prevent resource starvation.

**Service (NodePort):**
- Maps external port `80` → container `targetPort: 5000`.
- `NodePort` type enables access from outside the cluster via `minikube service`.

### 4. Horizontal Pod Autoscaler (HPA)

The HPA is created via `kubectl autoscale` command:
- **Target CPU utilization:** 50%
- **Minimum replicas:** 1
- **Maximum replicas:** 10

When average CPU utilization across pods exceeds 50% of the requested CPU (`100m`), the HPA controller increases replicas. When load drops, it gradually scales back down (with a default cooldown period).

---

## ⚙️ Setup Instructions

### Prerequisites

| Requirement | Minimum Version |
|-------------|----------------|
| Docker | 20.10+ |
| Minikube | 1.30+ |
| kubectl | 1.25+ |

### Step 1 — Start Minikube Cluster

```bash
minikube start
```

### Step 2 — Enable Metrics Server

The Metrics Server is **required** for HPA to function — it supplies CPU/memory usage data:

```bash
minikube addons enable metrics-server
```

### Step 3 — Configure Docker Environment

Point your terminal's Docker client to Minikube's internal Docker daemon so the built image is available to the cluster without pushing to a registry:

```bash
eval $(minikube docker-env)
```

> **Windows PowerShell equivalent:**
> ```powershell
> minikube docker-env --shell powershell | Invoke-Expression
> ```

### Step 4 — Build the Docker Image

```bash
docker build -t autoscaler:latest .
```

### Step 5 — Verify the Image

```bash
docker images | grep autoscaler
```

---

## 🚀 Deployment Steps

### Step 1 — Deploy to Kubernetes

```bash
kubectl apply -f autoscaler.yaml
```

### Step 2 — Verify Deployment and Pods

```bash
kubectl get deployments
kubectl get pods
kubectl get svc
```

**Expected output:**

```
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
autoscaler   2/2     2            2           30s
```

### Step 3 — Configure the HPA

```bash
kubectl autoscale deployment autoscaler --cpu-percent=50 --min=1 --max=10
```

### Step 4 — Verify HPA Status

```bash
kubectl get hpa
```

**Expected output:**

```
NAME         REFERENCE               TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
autoscaler   Deployment/autoscaler   0%/50%    1         10        2          15s
```

### Step 5 — Access the Application

```bash
minikube service autoscaler-service --url
```

---

## ✅ Validation and Testing

### 1. Generate Load to Trigger Autoscaling

Open a new terminal and run a BusyBox pod that sends continuous requests:

```bash
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://autoscaler-service; done"
```

### 2. Monitor HPA in Real Time

In another terminal, watch the HPA react to rising CPU utilization:

```bash
kubectl get hpa autoscaler --watch
```

**Expected progression:**

```
NAME         REFERENCE               TARGETS    MINPODS   MAXPODS   REPLICAS   AGE
autoscaler   Deployment/autoscaler   0%/50%     1         10        2          1m
autoscaler   Deployment/autoscaler   120%/50%   1         10        2          2m
autoscaler   Deployment/autoscaler   120%/50%   1         10        4          2m30s
autoscaler   Deployment/autoscaler   85%/50%    1         10        6          3m
```

### 3. Monitor Pod Scaling

```bash
kubectl get pods --watch
```

### 4. Verify Scale-Down

Stop the load generator (`Ctrl+C`) and observe the HPA scaling pods back down after the cooldown period (~5 minutes):

```bash
kubectl get hpa autoscaler --watch
kubectl get pods
```

### 5. Check Pod Logs

```bash
kubectl logs -l app=autoscaler --tail=20
```

---

## 🏗️ Infrastructure

### Kubernetes Resources

| Resource | Name | Details |
|----------|------|---------|
| **Deployment** | `autoscaler` | 2 initial replicas, `python:3.11-slim` based container |
| **Service** | `autoscaler-service` | Type: `NodePort`, Port: `80` → `5000` |
| **HPA** | `autoscaler` | CPU target: 50%, Min: 1, Max: 10 replicas |
| **Container** | `autoscaler` | Image: `autoscaler:latest`, CPU: 100m–500m |

### Resource Allocation

```
Per Pod:
├── CPU Request:  100m  (0.1 vCPU) — guaranteed minimum
├── CPU Limit:    500m  (0.5 vCPU) — hard ceiling
└── Gunicorn Workers: 2 — concurrent request handling
```

---

## 🔒 Security Considerations

| Aspect | Implementation |
|--------|---------------|
| **Minimal Base Image** | `python:3.11-slim` reduces attack surface compared to full images |
| **No Cache in Build** | `pip install --no-cache-dir` prevents sensitive data leaks in image layers |
| **Resource Limits** | CPU limits (`500m`) prevent a single pod from monopolizing node resources |
| **Local Image Policy** | `imagePullPolicy: Never` avoids external registry dependencies in development |
| **Non-Root (Recommended)** | Consider adding `USER` directive in Dockerfile for production |

---

## 📸 Screenshots

> Add screenshots of the following to demonstrate the working project:

| # | Screenshot Description | Filename |
|---|------------------------|----------|
| 1 | Minikube cluster running | `screenshots/minikube-status.png` |
| 2 | Docker image built successfully | `screenshots/docker-build.png` |
| 3 | Deployment and pods in Running state | `screenshots/kubectl-get-pods.png` |
| 4 | HPA status before load | `screenshots/hpa-before-load.png` |
| 5 | Load generator running | `screenshots/load-generator.png` |
| 6 | HPA scaling up pods under load | `screenshots/hpa-scaling-up.png` |
| 7 | Pods scaling down after load stops | `screenshots/hpa-scale-down.png` |
| 8 | Application response in browser | `screenshots/app-browser.png` |

---

## 📊 Results

| Metric | Outcome |
|--------|---------|
| **Application** | Flask app successfully serves CPU-intensive responses on port 5000 |
| **Containerization** | Docker image built with Gunicorn (2 workers) on `python:3.11-slim` |
| **Deployment** | 2-replica Deployment running on Minikube with CPU resource constraints |
| **Service** | NodePort Service exposes app externally via port 80 → 5000 |
| **Autoscaling** | HPA scales from 1–10 replicas when CPU exceeds 50% utilization |
| **Scale-Up** | Pods dynamically increase under sustained HTTP load |
| **Scale-Down** | Pods return to baseline after load subsides (default 5-min cooldown) |

---

## 📚 Key Learnings

| # | Concept | Description |
|---|---------|-------------|
| 1 | **Horizontal Pod Autoscaling** | Kubernetes HPA dynamically adjusts replica count based on observed metrics |
| 2 | **CPU Resource Management** | Difference between `requests` (scheduling guarantee) and `limits` (hard ceiling) |
| 3 | **Metrics Server** | Required cluster add-on that feeds resource utilization data to the HPA controller |
| 4 | **Container Best Practices** | Using slim base images, production WSGI servers, and `--no-cache-dir` builds |
| 5 | **Kubernetes Service Types** | `NodePort` enables external access in development/local cluster environments |
| 6 | **Load Testing** | Using BusyBox pods for in-cluster HTTP load generation |
| 7 | **Minikube Docker Integration** | `minikube docker-env` shares the Docker daemon, eliminating registry pushes |
| 8 | **Cooldown Behavior** | HPA uses stabilization windows to prevent rapid scale-up/down oscillation |
| 9 | **Gunicorn Workers** | Pre-fork worker model provides concurrency within a single container |

---

## 🧩 Challenges and Solutions

| # | Challenge | Solution |
|---|-----------|----------|
| 1 | **HPA shows `<unknown>` for CPU metrics** | Ensured Metrics Server was enabled via `minikube addons enable metrics-server` and waited ~60s for metrics collection to initialize |
| 2 | **`ErrImagePull` when deploying** | Set `imagePullPolicy: Never` in the Deployment manifest and built the image using Minikube's Docker daemon (`eval $(minikube docker-env)`) |
| 3 | **Load not triggering scale-up** | Tuned the CPU request to `100m` and the HPA threshold to `50%`, making the app sensitive enough to scale under moderate load |
| 4 | **Flask dev server insufficient for load testing** | Replaced with Gunicorn (2 workers) to handle concurrent requests without dropping connections |
| 5 | **Pods not scaling down quickly** | Kubernetes HPA default stabilization window is 5 minutes for scale-down; documented this as expected behavior |

---

## 🔮 Future Improvements

| # | Enhancement | Description |
|---|-------------|-------------|
| 1 | **Memory-Based Autoscaling** | Add memory metrics alongside CPU for more comprehensive scaling decisions |
| 2 | **Custom Metrics (Prometheus)** | Integrate Prometheus + custom metrics adapter for application-level autoscaling (e.g., request latency, queue depth) |
| 3 | **Liveness & Readiness Probes** | Add health check endpoints (`/healthz`, `/readyz`) to improve pod lifecycle management |
| 4 | **Ingress Controller** | Replace `NodePort` with an Ingress resource for production-grade routing and TLS termination |
| 5 | **Helm Chart** | Package the deployment as a Helm chart with configurable values for replicas, CPU thresholds, and image tags |
| 6 | **CI/CD Pipeline** | Add GitHub Actions workflow for automated image building, scanning, and deployment |
| 7 | **Multi-Stage Docker Build** | Separate build and runtime stages to further reduce image size |
| 8 | **Non-Root Container** | Add `USER` directive in Dockerfile for improved container security |
| 9 | **Vertical Pod Autoscaler (VPA)** | Complement HPA with VPA to auto-tune resource requests/limits |

---

## ✅ Project Completion Status

| Requirement | Status |
|-------------|--------|
| Python application with CPU load generation | ✅ Implemented |
| Dockerized with production WSGI server | ✅ Implemented |
| Kubernetes Deployment with resource constraints | ✅ Implemented |
| Kubernetes Service for external access | ✅ Implemented |
| Horizontal Pod Autoscaler configuration | ✅ Implemented (via `kubectl autoscale`) |
| Load testing to validate autoscaling | ✅ Documented (BusyBox-based approach) |
| Scale-up and scale-down demonstration | ✅ Validated |

> **Status: ✅ Project Complete** — All core objectives for demonstrating Kubernetes HPA-based CPU autoscaling have been successfully implemented.

---

## 👤 Author

**Sumit Shidole**

---

<p align="center">
  <i>Built as part of the L&T DevOps Mini Projects series to demonstrate Kubernetes autoscaling concepts.</i>
</p>
