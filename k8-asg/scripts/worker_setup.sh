#!/bin/bash
set -euo pipefail

# Set variables based on existing control-plane
K8_ENDPOINT="10.1.1.65:6443"
K8_TOKEN="6wwsqh.5rm3hmturbk9uxda"
K8_HASH="sha256:4b9ec01c6d193b833c1a63f081df1db10d56712b596c8f78e80820529d32d8a7"

# Set hostname to the EC2 private DNS name
AWS_TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

HOSTNAME=$(curl -H "X-aws-ec2-metadata-token: $AWS_TOKEN" \
  http://169.254.169.254/latest/meta-data/local-hostname)

hostnamectl set-hostname "$HOSTNAME"
systemctl restart systemd-logind.service

# Disable swap (Kubernetes requires this)
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

# Ensure required kernel modules are loaded on every boot
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# Set sysctl params required by Kubernetes networking
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl params without reboot
sysctl --system

# Install containerd
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release containerd

# Configure containerd
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml > /dev/null

# Enable Cgroup
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd

# Install Kubernetes repo
mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# Install ecr-credential-provider and configure it
curl -Lo /usr/bin/ecr-credential-provider https://storage.googleapis.com/k8s-staging-provider-aws/releases/v1.31.6-4-g3ffac90/linux/amd64/ecr-credential-provider-linux-amd64
chmod +x /usr/bin/ecr-credential-provider

cat <<EOT > /etc/kubernetes/image-credential-provider-config.yaml
apiVersion: kubelet.config.k8s.io/v1
kind: CredentialProviderConfig
providers:
- name: ecr-credential-provider
  matchImages:
  - "*.dkr.ecr.*.amazonaws.com"
  apiVersion: credentialprovider.kubelet.k8s.io/v1
  defaultCacheDuration: "0"
EOT

echo 'KUBELET_EXTRA_ARGS="--image-credential-provider-config=/etc/kubernetes/image-credential-provider-config.yaml --image-credential-provider-bin-dir=/usr/bin"' | tee -a /etc/default/kubelet
systemctl daemon-reexec
systemctl restart kubelet

# Create a config file
cat <<EOF | tee /etc/kubernetes/config.yaml
apiVersion: kubeadm.k8s.io/v1beta3
kind: JoinConfiguration
nodeRegistration:
  kubeletExtraArgs:
    cloud-provider: external
discovery:
  bootstrapToken:
    apiServerEndpoint: "${K8_ENDPOINT}"
    token: ${K8_TOKEN}
    caCertHashes:
      - ${K8_HASH}
EOF

kubeadm join --config /etc/kubernetes/config.yaml

systemctl enable kubelet
systemctl restart kubelet
