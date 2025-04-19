# Node.js Express App on EKS with ArgoCD & GitHub Actions

This repository demonstrates an end-to-end CI/CD setup to deploy a basic Node.js Express application on AWS EKS using Terraform, Helm, ArgoCD, and GitHub Actions.

---

## 🔧 Infrastructure (IaC)

Infrastructure is provisioned via Terraform and includes:

- **AWS EKS Cluster** with version 1.32
- **VPC, subnets, route tables, and internet gateway**
- **Node Group** (t3.medium) with public access
- **S3 Backend + DynamoDB** for remote Terraform state
- **IAM Role mappings** with `manage_aws_auth_configmap = true`
- **Secrets Management** via AWS Secrets Manager (GitHub, DockerHub, Slack)
- Separate modules and workspaces for `dev`, `staging`, and `prod`

---

## 🚀 Application Deployment with ArgoCD

- ArgoCD and ArgoCD Image Updater installed via Helm
- Custom `bootstrap.sh` script automates:
  - Creating secrets
  - Installing ArgoCD and Image Updater
  - Setting up Slack notifications
  - Applying environment-specific ArgoCD Applications

---

## ⚙️ CI/CD Pipelines (GitHub Actions)

### 🟩 Terraform

- `terraform.yaml`: 
  - Triggered on Pull Request
  - Runs `fmt`, `validate`, `plan`
  - **No apply on PR**  
  - On merge to `master`, executes `apply` with manual approval (if enabled)
  - Uses GitHub Secrets for sensitive variables

### 🟨 Application

- `docker-build-push.yaml`:  
  - Triggered on changes to `app/`, `Dockerfile`, or `package.json`
  - Builds & tags Docker image as `1.0.<run_number>`
  - Pushes image to Docker Hub
  - ArgoCD Image Updater automatically syncs with the latest tag

### 🟦 Pull Request Validator

- `pr-validate.yaml` (example):
  - Triggered on **pull requests**
  - Runs basic Node.js checks (e.g., `npm install`, fake lint, fake test)
  - Ensures safe merges even without actual tests or linters

---

## 📦 Helm & ArgoCD Apps

- Helm chart located at `helm/nodejs-express-mysql`
- Values files per environment: `values-dev.yaml`, `values-staging.yaml`, `values-prod.yaml`
- ArgoCD Applications defined under `argocd-manifests/applications/`
- Image updates are handled automatically via ArgoCD Image Updater

---

## 📈 Scalability

- **Horizontal Pod Autoscaler (HPA)** enabled via Helm values
- **metrics-server** deployed using Helm
- App scales based on CPU utilization

---

## 🔔 Slack Notifications

- Slack Bot Token securely fetched from **AWS Secrets Manager**
- ArgoCD sends notifications:
  - ✅ `on-sync-succeeded`
  - ❌ `on-sync-failed`
- Messages posted to `#all-cloudopscenter` channel

---

## 📁 Project Structure

| Path                                      | Description                                            |
|-------------------------------------------|--------------------------------------------------------|
| `.github/workflows/terraform.yaml`        | CI pipeline for Terraform (fmt, validate, plan, apply) |
| `.github/workflows/bootstrap.yaml`        | Post-Terraform ArgoCD setup & secrets                  |
| `.github/workflows/docker-build-push.yaml`| Build & push Docker image on master changes            |
| `.github/workflows/pr-validate.yaml`      | PR validation (npm install, lint, test placeholders)   |
| `terraform/backend/`                      | Remote state backend (S3 & DynamoDB)                   |
| `terraform/k8s-setup/`                    | VPC, EKS, IAM setup modules                            |
| `helm/nodejs-express-mysql/`              | Helm chart for Node.js app with HPA support            |
| `helm/nodejs-express-mysql/templates/`    | Helm templates                                         |
| `helm/nodejs-express-mysql/values-*.yaml` | Dev/Staging/Prod values                                |
| `argocd-manifests/applications/`          | ArgoCD Applications for each environment               |
| `argocd-manifests/image-updater/`         | ArgoCD Image Updater Helm values                       |
| `bootstrap.sh`                            | ArgoCD setup automation                                |
| `README.md`                               | Case documentation                                     |

---

## 👤 Maintainer

**Emre Karaaslan**  
📧 memrekaraaslan@gmail.com  
🔗 [github.com/memrekaraaslan](https://github.com/memrekaraaslan)
