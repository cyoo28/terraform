#!/bin/bash
set -euo pipefail

# Set variables based on existing control-plane
K8_ENDPOINT="10.1.1.123:6443"
K8_TOKEN="sg3bwv.mql5r1pwg2rut96b"
K8_HASH= "sha256:ccb53523397d29e4965591a296af98af018090ac0f6a56d9d8618450572d670a"

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

sysctl --system

# Install containerd
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release containerd

# Enable Cgroup
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

# Configure containerd with systemd cgroups
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml > /dev/null
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd

# Install Kubernetes repo
mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

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