variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "cluster_name" {
  description = "EKS Cluster name"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
}

variable "github_username" {
  description = "GitHub username for ArgoCD Git push"
  type        = string
  sensitive   = true
}

variable "github_pat" {
  description = "GitHub personal access token for ArgoCD Git push"
  type        = string
  sensitive   = true
}

variable "github_repo_url" {
  description = "GitHub repository URL"
  type        = string
}

variable "dockerhub_dockerconfigjson" {
  description = "Base64-encoded Docker config JSON for image pull authentication"
  type        = string
  sensitive   = true
}

variable "slack_bot_token_value" {
  description = "Slack Notification Token"
  type        = string
  sensitive   = true
}