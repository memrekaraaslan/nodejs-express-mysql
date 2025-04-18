resource "aws_secretsmanager_secret" "git_creds" {
  name        = "git-creds"
  description = "GitHub credentials for ArgoCD Image Updater push access"
}

resource "aws_secretsmanager_secret_version" "git_creds" {
  secret_id = aws_secretsmanager_secret.git_creds.id
  secret_string = jsonencode({
    username = var.github_username
    password = var.github_pat
    url      = var.github_repo_url
  })
}

resource "aws_secretsmanager_secret" "dockerhub" {
  name        = "dockerhub-credentials"
  description = "Docker Hub credentials for ArgoCD Image Updater"
}

resource "aws_secretsmanager_secret_version" "dockerhub" {
  secret_id = aws_secretsmanager_secret.dockerhub.id
  secret_string = jsonencode({
    dockerconfigjson = var.dockerhub_dockerconfigjson
  })
}

resource "aws_secretsmanager_secret" "slack_bot_token" {
  name        = "slack-bot-token"
  description = "Slack Bot Token for ArgoCD notifications"
}

resource "aws_secretsmanager_secret_version" "slack_bot_token_version" {
  secret_id = aws_secretsmanager_secret.slack_bot_token.id
  secret_string = jsonencode({
    token = var.slack_bot_token
  })
}