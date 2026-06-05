# 🧮 Python CI Pipeline for a Simple Calculator

## 📌 Project Overview

This project demonstrates the implementation of a **Continuous Integration (CI) Pipeline** using **GitHub Actions** for a Python-based Calculator application.

The goal of this project is to automate code quality checks, unit testing, and code coverage analysis whenever new code is pushed to the repository or a Pull Request is created.

By integrating automated validation into the development workflow, the project follows modern **DevOps Continuous Integration best practices**.

---

## 🎯 Objectives

* Develop a simple Python Calculator application.
* Implement automated testing using Pytest.
* Enforce code quality using Flake8.
* Generate code coverage reports.
* Build an automated CI workflow using GitHub Actions.
* Demonstrate DevOps Continuous Integration practices.

---

## 🏗 Architecture

```text
Developer Push / Pull Request
            │
            ▼
     GitHub Repository
            │
            ▼
      GitHub Actions
            │
 ┌──────────┼──────────┐
 │          │          │
 ▼          ▼          ▼
Linting   Testing   Coverage
(Flake8)  (Pytest)  (pytest-cov)
 │          │          │
 └──────────┴──────────┘
            │
            ▼
      Build Status
```

---

## 🛠 Technologies Used

| Technology     | Purpose                 |
| -------------- | ----------------------- |
| Python         | Application Development |
| Pytest         | Unit Testing Framework  |
| pytest-cov     | Code Coverage Reporting |
| Flake8         | Code Linting            |
| GitHub Actions | Continuous Integration  |
| Git            | Version Control         |

---

## 📂 Project Structure

```text
calculator-ci-project/
│
├── calculator.py
├── test_calculator.py
├── requirements.txt
│
└── .github/
    └── workflows/
        └── ci.yml
```

---

## ⚙ Implementation Details

### calculator.py

Contains arithmetic functions:

* Addition
* Subtraction
* Multiplication
* Division

Includes validation for division by zero.

### test_calculator.py

Contains unit tests covering all calculator functions.

### GitHub Actions Workflow

The CI workflow automatically:

1. Checks out source code
2. Sets up Python environment
3. Installs dependencies
4. Runs Flake8 linting
5. Executes Pytest unit tests
6. Generates coverage reports

---

## 🚀 Local Setup

### Clone Repository

```bash
git clone <repository-url>
cd calculator-ci-project
```

### Create Virtual Environment

```bash
python -m venv venv
```

### Activate Virtual Environment

Windows:

```bash
venv\Scripts\activate
```

Linux/Mac:

```bash
source venv/bin/activate
```

### Install Dependencies

```bash
pip install -r requirements.txt
```

---

## ✅ Validation & Testing

### Run Linting

```bash
flake8 .
```

### Run Unit Tests

```bash
pytest
```

### Run Coverage Report

```bash
pytest --cov=calculator
```

---

## 🔄 CI Pipeline Workflow

### Trigger Events

* Push to `main`
* Pull Request to `main`

### Pipeline Stages

#### 1. Checkout Code

Downloads repository contents.

#### 2. Setup Python

Installs Python 3.12 environment.

#### 3. Install Dependencies

Installs all required packages.

#### 4. Run Flake8

Performs static code analysis.

#### 5. Run Pytest

Executes unit tests.

#### 6. Generate Coverage Report

Measures test coverage.

---

## 📊 Expected Output

Successful workflow execution will show:

```text
✔ Lint Passed
✔ Tests Passed
✔ Coverage Generated
✔ Workflow Successful
```

---

## 📸 Screenshots

### Successful GitHub Actions Run

Add screenshot here:

```text
screenshots/successful-run.png
```

### Failed Pipeline Example

Add screenshot here:

```text
screenshots/failed-run.png
```

### Coverage Report

Add screenshot here:

```text
screenshots/coverage-report.png
```

---

## 🎓 Key Learnings

* Continuous Integration Fundamentals
* GitHub Actions Workflow Development
* Automated Testing with Pytest
* Static Code Analysis using Flake8
* Code Coverage Reporting
* DevOps Automation Practices

---

## ⚠ Challenges Faced

### Challenge

Ensuring every code change maintains quality standards.

### Solution

Integrated Flake8 and Pytest into the CI pipeline to automatically validate every commit and pull request.

---

## 🔮 Future Improvements

* Add GitHub Actions Status Badge
* Support Multiple Python Versions
* Publish Package to PyPI
* Add Security Scanning
* Implement Continuous Deployment (CD)

---

## 📈 Project Outcome

✔ Automated CI Pipeline Implemented

✔ Unit Testing Integrated

✔ Code Quality Validation Automated

✔ Coverage Reporting Enabled

✔ GitHub Actions Successfully Configured

---

## 🏁 Project Status

**Completed Successfully**

This project fully satisfies the objective of demonstrating a Python-based Continuous Integration pipeline using GitHub Actions with automated testing, linting, and coverage reporting.

---

## 👨‍💻 Author

**Sumit Shidole**

Computer Engineering Student | DevOps Learner | Python Developer
