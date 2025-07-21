#!/bin/bash
set -euo pipefail

# Set hostname to the EC2 private DNS name (required for cloud controller)
AWS_TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

HOSTNAME=$(curl -H "X-aws-ec2-metadata-token: $AWS_TOKEN" \
  http://169.254.169.254/latest/meta-data/local-hostname)

PRIVATE_IP=$(curl -H "X-aws-ec2-metadata-token: $AWS_TOKEN" \
  http://169.254.169.254/latest/meta-data/local-ipv4)

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

# Create a config file
cat <<EOF | sudo tee /etc/kubernetes/kubeadmn-custom.yaml
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
nodeRegistration:
  kubeletExtraArgs:
    cloud-provider: external
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
apiServer:
  extraArgs:
    cloud-provider: external
  certSANs:
    - "${PRIVATE_IP}"
    - "${HOSTNAME}"
scheduler:
  extraArgs:
controllerManager:
  extraArgs:
    cloud-provider: external
networking:
  podSubnet: "192.168.0.0/16"
EOF

# Initialize the Kubernetes cluster
sudo kubeadm init --config /etc/kubernetes/kubeadmn-custom.yaml

# Set up kubeconfig for ubuntu user (if running as root use /root instead)
mkdir -p /home/ubuntu/.kube
cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
chown -R ubuntu:ubuntu /home/ubuntu/.kube

# Create a script to setup the cluster
cat <<'EOF'> /home/ubuntu/cluster-setup.sh
#!/bin/bash
set -e

# Print the kubeadm join command for worker nodes
echo "Worker node join command:"
kubeadm token create --ttl 0 --print-join-command

# Create the role binding and the user
kubectl create clusterrolebinding admin-role --clusterrole=cluster-admin --user=admin

# Generate a kube config file
sudo kubeadm kubeconfig user --client-name=admin | tee /home/ubuntu/admin.conf
EOF

chmod +x /home/ubuntu/cluster-setup.sh
chown ubuntu:ubuntu /home/ubuntu/cluster-setup.sh

# Create a script to add addons
cat <<'EOF'> /home/ubuntu/addons-setup.sh
#!/bin/bash
set -e

# Install AWS cloud provider
kubectl apply -k 'github.com/kubernetes/cloud-provider-aws/tree/master/examples/existing-cluster/base?ref=master'
                  
# Install Calico CNI
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/calico.yaml
EOF

chmod +x /home/ubuntu/addons-setup.sh
chown ubuntu:ubuntu /home/ubuntu/addons-setup.sh