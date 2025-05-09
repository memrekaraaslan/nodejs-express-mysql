#!/bin/bash
set -euo pipefail

### 1. HELPER FUNCTIONS
log() {
  echo -e "\033[1;32m[bootstrap $(date +'%H:%M:%S')]\033[0m $1"
}

### 2. LOAD GITHUB SECRETS FROM ENV
GITHUB_USERNAME=${GITHUB_USERNAME:-}
GITHUB_PAT=${GITHUB_PAT:-}
GITHUB_REPO_URL=${GITHUB_REPO_URL:-}
DOCKERHUB_CONFIG_JSON=${DOCKERHUB_DOCKERCONFIGJSON:-}

if [[ -z "$GITHUB_USERNAME" || -z "$GITHUB_PAT" || -z "$GITHUB_REPO_URL" || -z "$DOCKERHUB_CONFIG_JSON" ]]; then
  echo "❌ Environment variables missing. Make sure secrets are set in GitHub Actions."
  exit 1
fi

### 3. CREATE K8S SECRETS IN argocd NAMESPACE
log "Creating Kubernetes secrets for ArgoCD"
kubectl create ns argocd --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: dockerhub-secret
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
data:
  .dockerconfigjson: "$DOCKERHUB_CONFIG_JSON"
type: kubernetes.io/dockerconfigjson
EOF

kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: git-creds
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  url: "$GITHUB_REPO_URL"
  username: "$GITHUB_USERNAME"
  password: "$GITHUB_PAT"
type: Opaque
EOF

### 4. INSTALL ArgoCD & Image Updater
log "Installing ArgoCD via Helm"
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  --set server.service.type=ClusterIP

log "Waiting for ArgoCD server to be ready..."
kubectl rollout status deployment/argocd-server -n argocd --timeout=60s

log "Installing ArgoCD Image Updater via Helm"
helm upgrade --install argocd-image-updater argo/argocd-image-updater \
  --namespace argocd \
  -f argocd-manifests/image-updater/values.yaml

### 5. INSTALL METRICS SERVER
log "Installing metrics-server for HPA"
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
helm upgrade --install metrics-server metrics-server/metrics-server \
  -n kube-system \
  --create-namespace \
  --set args={--kubelet-insecure-tls}

### 6. CONFIGURE SLACK NOTIFICATIONS
log "Retrieving Slack Token from AWS Secrets Manager"
SLACK_BOT_TOKEN=$(aws secretsmanager get-secret-value \
  --secret-id slack-bot-token \
  --query 'SecretString' \
  --output text | jq -r .token)

if [[ -z "$SLACK_BOT_TOKEN" ]]; then
  echo "❌ Slack Bot Token could not be retrieved from Secrets Manager."
  exit 1
fi

log "Creating ArgoCD notifications ConfigMap"
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-notifications-cm
  namespace: argocd
  labels:
    app.kubernetes.io/name: argocd-notifications-cm
    app.kubernetes.io/part-of: argocd
data:
  context: |
    argocdUrl: http://argocd.argocd.svc.cluster.local
  service.slack: |
    token: ${SLACK_BOT_TOKEN}
  trigger.on-sync-succeeded: |
    - when: app.status.operationState.phase == 'Succeeded'
      send: [slack-on-sync-succeeded]
  trigger.on-sync-failed: |
    - when: app.status.operationState.phase == 'Failed'
      send: [slack-on-sync-failed]
  template.slack-on-sync-succeeded: |
    message: |
      *{{.app.metadata.name}}* sync succeeded.
      {{.context.argocdUrl}}/applications/{{.app.metadata.name}}
  template.slack-on-sync-failed: |
    message: |
      *{{.app.metadata.name}}* sync failed.
      {{.context.argocdUrl}}/applications/{{.app.metadata.name}}
EOF

log "Creating ArgoCD notifications Secret"
kubectl create secret generic argocd-notifications-secret \
  --namespace argocd \
  --from-literal=slack-bot-token="$SLACK_BOT_TOKEN" \
  --dry-run=client -o yaml | kubectl apply -f -

### 7. DEPLOY ArgoCD APPLICATIONS
log "Applying ArgoCD Applications"
kubectl apply -f argocd-manifests/applications/

log "✅ Bootstrap completed."