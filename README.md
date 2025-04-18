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

## ⚙️ CI/CD Pipelines

Implemented using **GitHub Actions**:

- `terraform.yaml`: 
  - Runs `fmt`, `validate`, `plan`, and `apply` with PR flow
  - Uses GitHub Secrets for secure variable injection
- `bootstrap.yaml`: 
  - Installs ArgoCD, syncs applications, sets up notification system

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

- Slack Bot Token stored in AWS Secrets Manager
- Notifications configured for:
  - `on-sync-succeeded`
  - `on-sync-failed`
- Sent to `#all-cloudopscenter` channel

---

## 📁 Project Structure
.
├── .github/
│   └── workflows/
│       ├── terraform.yaml           # CI pipeline for Terraform (fmt, validate, plan, apply)
│       └── bootstrap.yaml           # Post-Terraform ArgoCD setup & secrets
├── terraform/
│   ├── backend/                     # Remote state backend (S3 & DynamoDB)
│   └── k8s-setup/                   # VPC, EKS, IAM setup modules
├── helm/
│   └── nodejs-express-mysql/       # Helm chart for app with HPA support
│       ├── templates/
│       └── values-*.yaml            # Dev/Staging/Prod values
├── argocd-manifests/
│   ├── applications/               # ArgoCD Application CRs for each environment
│   └── image-updater/              # ArgoCD Image Updater Helm values
├── bootstrap.sh                    # ArgoCD setup automation
└── README.md


---

## 👤 Maintainer

**Emre Karaaslan**  
📧 memrekaraaslan@gmail.com  
🔗 [github.com/memrekaraaslan](https://github.com/memrekaraaslan)