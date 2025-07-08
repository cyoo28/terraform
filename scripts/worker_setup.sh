#!/bin/bash
set -euo pipefail

# Load necessary kernel modules
modprobe overlay
modprobe br_netfilter

# Set sysctl params required by Kubernetes networking
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl --system

# Disable swap (required by kubeadm)
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

# Install Docker
apt-get update
apt-get install -y docker.io
systemctl enable --now docker

# Add Kubernetes apt repository and install kubelet, kubeadm, kubectl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
systemctl enable --now kubelet