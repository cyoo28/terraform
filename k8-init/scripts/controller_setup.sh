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
cat <<EOF | sudo tee /etc/kubernetes/kubeadm-custom.yaml
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
clusterName: my-cluster
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
sudo kubeadm init --config /etc/kubernetes/kubeadm-custom.yaml

# Set up kubeconfig for ubuntu user (if running as root use /root instead)
mkdir -p /home/ubuntu/.kube
cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
chown -R ubuntu:ubuntu /home/ubuntu/.kube

# Create a script for join command
cat <<'EOF'> /home/ubuntu/join-setup.sh
#!/bin/bash
set -e

# Print the kubeadm join command for worker nodes
echo "Worker node join command:"
kubeadm token create --ttl 0 --print-join-command
EOF

chmod +x /home/ubuntu/join-setup.sh
chown ubuntu:ubuntu /home/ubuntu/join-setup.sh

# Create a script to add addons
cat <<'EOF'> /home/ubuntu/addon-setup.sh
#!/bin/bash
set -e

# Install AWS cloud provider
kubectl apply -k 'github.com/kubernetes/cloud-provider-aws/examples/existing-cluster/base/?ref=master'
                  
# Install Weave Net CNI
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
EOF

chmod +x /home/ubuntu/addon-setup.sh
chown ubuntu:ubuntu /home/ubuntu/addon-setup.sh

# Create script to start kube2iam
cat <<EOF > /home/ubuntu/kube2iam.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kube2iam
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kube2iam
rules:
  - apiGroups: [""]
    resources: ["namespaces", "pods"]
    verbs: ["get", "watch", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kube2iam
subjects:
  - kind: ServiceAccount
    name: kube2iam
    namespace: kube-system
roleRef:
  kind: ClusterRole
  name: kube2iam
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: kube2iam
  namespace: kube-system
  labels:
    app: kube2iam
spec:
  selector:
    matchLabels:
      app: kube2iam
  template:
    metadata:
      labels:
        app: kube2iam
    spec:
      serviceAccountName: kube2iam
      hostNetwork: true
      containers:
        - name: kube2iam
          image: docker.io/jtblin/kube2iam:latest
          imagePullPolicy: Always
          args:
            - "--app-port=8181"
            - "--auto-discover-base-arn"
            - "--host-ip=127.0.0.1"
            - "--host-interface=weave"
            - "--iptables"
            - "--verbose"
          env:
            - name: AWS_REGION
              value: us-east-1
          ports:
            - containerPort: 8181
              hostPort: 8181
              name: http
          securityContext:
            privileged: true
EOF

chown ubuntu:ubuntu /home/ubuntu/kube2iam.yaml

systemctl enable kubelet
systemctl restart kubelet