#!/bin/bash
set -euo pipefail

# Disable swap (Kubernetes requires this)
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

# Enable kernel modules and sysctl
modprobe overlay
modprobe br_netfilter

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sysctl --system

# Install Docker
apt update
apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
apt install -y docker.io
systemctl enable --now docker

# Install Kubernetes repo
mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" > /etc/apt/sources.list.d/kubernetes.list

apt update
apt install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# Initialize the Kubernetes cluster (only on control plane)
kubeadm init --pod-network-cidr=192.168.0.0/16

# Set up kubeconfig for ubuntu user (if running as root use /root instead)
mkdir -p /home/ubuntu/.kube
cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
chown ubuntu:ubuntu /home/ubuntu/.kube/config

# Install Calico CNI
sudo -u ubuntu kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
