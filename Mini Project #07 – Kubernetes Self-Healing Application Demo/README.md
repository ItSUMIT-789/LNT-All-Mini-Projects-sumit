# 🚀 Mini Project #07 – Kubernetes Self-Healing Application Demo

## 📌 Project Overview

This project demonstrates Kubernetes' self-healing capability using a Deployment running multiple replicas of an Nginx web application on Minikube.

The application is deployed using Kubernetes Deployments and exposed using a NodePort Service. A pod is intentionally deleted to demonstrate how Kubernetes automatically recreates failed containers and maintains the desired application state.

This project showcases one of Kubernetes' core features: **Self-Healing Infrastructure**.

---

# 🎯 Project Objective

Deploy a web application on Minikube with:

* Kubernetes Deployment
* 3 Replicas
* NodePort Service
* Automatic Pod Recovery
* Self-Healing Demonstration

and provide visual proof that Kubernetes automatically recreates failed pods.

---

# 🏗 Architecture

```text
                    +------------------+
                    |    Minikube      |
                    +---------+--------+
                              |
                    +---------v--------+
                    |   Deployment     |
                    |   Replicas = 3   |
                    +---------+--------+
                              |
          +-------------------+-------------------+
          |                   |                   |
    +-----v-----+       +-----v-----+       +-----v-----+
    |  Pod #1   |       |  Pod #2   |       |  Pod #3   |
    |  Nginx    |       |  Nginx    |       |  Nginx    |
    +-----------+       +-----------+       +-----------+

                              |
                              |
                    +---------v--------+
                    | NodePort Service |
                    +---------+--------+
                              |
                              |
                        Browser Access
```

---

# 🛠 Technologies Used

| Technology | Purpose                   |
| ---------- | ------------------------- |
| Kubernetes | Container Orchestration   |
| Minikube   | Local Kubernetes Cluster  |
| kubectl    | Kubernetes CLI            |
| YAML       | Infrastructure Definition |
| Nginx      | Demo Web Application      |

---

# 📂 Project Structure

```text
Lab2/
│
├── deployment.yaml
├── service.yaml
├── README.md
└── screenshots/
```

---

# 📄 Deployment Configuration

## Deployment

* Kubernetes Deployment
* Nginx Container
* Resource Requests & Limits
* 3 Replicas

```yaml
replicas: 3
```

---

## Service

Service Type:

```yaml
type: NodePort
```

Purpose:

* Expose application externally
* Allow browser access from Minikube

---

# 🚀 Deployment Steps

## 1. Start Minikube

```bash
minikube start
```

Verify:

```bash
minikube status
```

---

## 2. Deploy Application

```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

---

## 3. Verify Deployment

```bash
kubectl get deployments
```

Expected:

```text
NAME     READY   UP-TO-DATE   AVAILABLE
my-app   3/3     3            3
```

---

## 4. Verify Pods

```bash
kubectl get pods
```

Expected:

```text
my-app-xxxxx   Running
my-app-yyyyy   Running
my-app-zzzzz   Running
```

---

## 5. Verify Service

```bash
kubectl get svc
```

Expected:

```text
my-service   NodePort
```

---

## 6. Access Application

Get Service URL:

```bash
minikube service my-service --url
```

Open the generated URL in a browser.

---

# 🔄 Kubernetes Self-Healing Demonstration

One of Kubernetes' most important capabilities is maintaining the desired state of applications.

If a pod crashes or is deleted, Kubernetes automatically recreates it.

---

## Step 1 – Watch Pods

Open Terminal 1:

```bash
kubectl get pods -w
```

---

## Step 2 – Delete a Pod

Open Terminal 2:

```bash
kubectl delete pod <pod-name>
```

Example:

```bash
kubectl delete pod my-app-78c44b6b4-xq46h
```

---

## Step 3 – Observe Recovery

Kubernetes automatically creates a replacement pod.

Example output:

```text
my-app-78c44b6b4-xq46h   Terminating

my-app-78c44b6b4-zdr4g   Running

my-app-78c44b6b4-ab123   ContainerCreating

my-app-78c44b6b4-ab123   Running
```

This confirms Kubernetes self-healing functionality.

---

# 📸 Screenshots

Add screenshots here.

## Deployment Running

![Deployment](screenshots/deployment.png)

---

## Three Pods Running

![Pods](screenshots/pods.png)

---

## NodePort Service

![Service](screenshots/service.png)

---

## Pod Deletion

![Delete Pod](screenshots/delete-pod.png)

---

## Kubernetes Auto Recovery

![Recovery](screenshots/recovery.png)

---

# 📊 Results

Successfully demonstrated:

✅ Kubernetes Deployment

✅ Multiple Replicas

✅ NodePort Service

✅ Minikube Deployment

✅ Resource Management

✅ Pod Monitoring

✅ Automatic Pod Recovery

✅ Kubernetes Self-Healing

---

# 🎓 Learning Outcomes

Through this project, I learned:

* Kubernetes Architecture
* Deployments and ReplicaSets
* Service Exposure using NodePort
* Minikube Cluster Management
* Pod Lifecycle Management
* Kubernetes Self-Healing Mechanism
* kubectl Operations
* YAML-based Infrastructure Definition

---

# 🔥 Key Kubernetes Concept Demonstrated

Kubernetes continuously compares:

```text
Desired State
```

with

```text
Actual State
```

If a pod is deleted:

```text
Desired Pods = 3
Actual Pods = 2
```

Kubernetes automatically creates a new pod until:

```text
Desired Pods = Actual Pods
```

This mechanism is called **Self-Healing**.

---

# ✅ Project Status

**Mini Project #07 – Completed**

Completion Status: **100%**

Demonstrated Kubernetes self-healing using Minikube, Deployments, ReplicaSets, and NodePort Services.

---

# 👨‍💻 Author

**Sumit Shidole**

B.E. Computer Engineering Student

DevOps • Cloud • Kubernetes • CI/CD Enthusiast
