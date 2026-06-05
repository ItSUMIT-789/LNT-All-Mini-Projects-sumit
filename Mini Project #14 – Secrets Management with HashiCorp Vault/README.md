# 🔐 Mini Project #14 – Secrets Management with HashiCorp Vault

![DevSecOps](https://img.shields.io/badge/DevSecOps-Security-blue)
![Vault](https://img.shields.io/badge/HashiCorp-Vault-black)
![GitHub Actions](https://img.shields.io/badge/GitHub-Actions-success)
![Docker](https://img.shields.io/badge/Docker-Compose-blue)
![Python](https://img.shields.io/badge/Python-Flask-green)

## 📌 Project Overview

This project demonstrates secure secrets management using **HashiCorp Vault**, **Docker Compose**, **Flask**, and **GitHub Actions**.

Instead of storing credentials directly inside source code, Dockerfiles, or configuration files, secrets are stored securely in Vault and retrieved dynamically by the application at runtime.

The project follows DevSecOps best practices by:

* Centralizing secret storage
* Avoiding secret exposure in logs
* Retrieving credentials at runtime
* Integrating secret management into CI/CD workflows

---

# 🎯 Project Objective

Implement a secure secrets management solution using:

* HashiCorp Vault
* GitHub Actions
* Docker Compose
* Python Flask

while ensuring:

✅ No secrets exposed in application logs

✅ Runtime secret retrieval

✅ Secure CI/CD integration

✅ DevSecOps workflow implementation

---

# 🏗 Architecture

```text
+----------------------+
| GitHub Actions       |
+----------+-----------+
           |
           v
+----------------------+
| HashiCorp Vault      |
| Secret Storage       |
+----------+-----------+
           |
           v
+----------------------+
| Flask Application    |
| Runtime Retrieval    |
+----------+-----------+
           |
           v
+----------------------+
| Masked Secret Output |
+----------------------+
```

---

# 🛠 Technology Stack

| Technology      | Purpose                 |
| --------------- | ----------------------- |
| Python Flask    | Application             |
| HashiCorp Vault | Secret Management       |
| Docker Compose  | Container Orchestration |
| GitHub Actions  | CI/CD Pipeline          |
| Pytest          | Testing                 |
| Pylint          | Static Code Analysis    |
| Docker Hub      | Image Registry          |

---

# 📂 Project Structure

```text
.
├── app.py
├── Dockerfile
├── docker-compose.yml
├── vault-init.sh
├── requirements.txt
├── test_app.py
├── .env.example
├── README.md
└── .github
    └── workflows
        └── ci.yml
```

---

# 🔑 Secret Management Workflow

```text
Environment Variables
          │
          ▼
     Vault Init
          │
          ▼
  HashiCorp Vault
          │
          ▼
 Flask Application
          │
          ▼
 Runtime Secret Retrieval
          │
          ▼
    Masked Output
```

---

# 🚀 Setup Instructions

## Clone Repository

```bash
git clone <repository-url>
cd <repository-name>
```

---

## Create Environment File

```bash
cp .env.example .env
```

Update values as needed.

---

## Start Services

```bash
docker compose up -d --build
```

---

## Verify Containers

```bash
docker ps
```

Expected containers:

```text
vault
vault-init
sample-app
```

---

# 🔍 Verification

## Vault Initialization

```bash
docker logs vault-init
```

Expected:

```text
Vault initialization completed successfully
```

---

## Application Logs

```bash
docker logs sample-app
```

Expected:

```text
Successfully connected to Vault
Successfully retrieved secrets
DB Password: ********
API Key: ********
```

---

## Health Endpoint

```bash
curl http://localhost:5000/health
```

Expected:

```json
{
  "status": "healthy"
}
```

---

## Secret Endpoint

```bash
curl http://localhost:5000/secrets
```

Expected:

```json
{
  "status": "success",
  "db_password": "********",
  "api_key": "********"
}
```

---

# ⚙ GitHub Actions Pipeline

The CI/CD pipeline performs:

### Python Setup

* Checkout source code
* Configure Python

### Testing Stage

* Install dependencies
* Run Pytest
* Generate HTML reports

### Static Analysis

* Execute Pylint
* Upload reports as artifacts

### Vault Demonstration

* Start Vault service
* Store secrets
* Retrieve secrets securely
* Mask secret values

### Docker Build & Push

* Login to Docker Hub
* Build Docker image
* Push image to registry

---

# 🔒 Security Controls Implemented

### Secret Storage

Secrets stored in HashiCorp Vault.

### Runtime Retrieval

Application retrieves credentials only when needed.

### Secret Masking

GitHub Actions masks secret values:

```bash
echo "::add-mask::$DB_PASS"
echo "::add-mask::$API_KEY"
```

### No Secret Exposure

Application logs display:

```text
********
```

instead of actual values.

---

# 📊 Project Outcome

Successfully implemented:

* HashiCorp Vault
* Secure Secret Storage
* Runtime Secret Retrieval
* Docker Compose Orchestration
* Flask Integration
* GitHub Actions Integration
* DevSecOps Security Practices

---

# 📸 Screenshots

Add screenshots here:

### Docker Containers Running

![Docker Screenshot](screenshots/docker-running.png)

### Vault Initialization

![Vault Screenshot](screenshots/vault-init.png)

### Flask Application Logs

![Logs Screenshot](screenshots/app-logs.png)

### GitHub Actions Pipeline

![Pipeline Screenshot](screenshots/github-actions.png)

---

# 🎓 Skills Demonstrated

* DevSecOps
* HashiCorp Vault
* Docker Compose
* CI/CD Pipelines
* GitHub Actions
* Secure Application Development
* Secret Management
* Python Flask
* Containerization

---

# ✅ Project Status

**Mini Project #14 – Completed**

Completion: **100%**

Implemented as part of a DevOps learning program focused on modern Infrastructure, Automation, Security, and CI/CD practices.

---

# 👨‍💻 Author

**Sumit Shidole**

Computer Engineering Student
DevOps & Cloud Enthusiast

---

# 📜 License

This project is intended for educational and learning purposes.
