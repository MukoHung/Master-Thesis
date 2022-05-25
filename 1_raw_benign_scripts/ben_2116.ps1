# Default env vars
$env:CLUSTER_NAME="k3d-rancher"
$env:RANCHER_SERVER_HOSTNAME="rancher.localhost"
$env:KUBECONFIG_FILE="${env:CLUSTER_NAME}.yaml"
date

# Get kubectl and helm
choco list --local-only
choco install kubernetes-cli -y
choco install kubernetes-helm -y

# Get k3d
wget https://github.com/rancher/k3d/releases/download/v3.2.0/k3d-windows-amd64.exe -o k3d-windows-amd64-3.2.0.exe
Set-Alias -Name k3d -Value .\k3d-windows-amd64-3.2.0.exe

k3d cluster stop $env:CLUSTER_NAME
k3d cluster delete $env:CLUSTER_NAME

# Create the cluster
k3d cluster create $env:CLUSTER_NAME --api-port 6550 --servers 1 --port 443:443@loadbalancer --wait

k3d cluster list
k3d kubeconfig get ${env:CLUSTER_NAME} > $env:KUBECONFIG_FILE

$env:KUBECONFIG=($env:KUBECONFIG_FILE)

kubectl get nodes

# https://rancher.com/docs/rancher/v2.x/en/installation/k8s-install/helm-rancher/
# Install cert-manager with helm
helm repo add jetstack https://charts.jetstack.io
helm repo update
kubectl create namespace cert-manager
helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.0.4 --set installCRDs=true --wait
kubectl -n cert-manager rollout status deploy/cert-manager
date

# Install Rancher
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo update
kubectl create namespace cattle-system
helm install rancher rancher-latest/rancher --namespace cattle-system --set hostname=${env:RANCHER_SERVER_HOSTNAME} --wait
kubectl -n cattle-system rollout status deploy/rancher
date


# Optionally purge your Docker env
# docker rm -f $(docker ps -qa)
# docker network prune -f
# docker volume prune -
# docker system prune -a -f
