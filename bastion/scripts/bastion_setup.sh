#!/bin/bash
set -euo pipefail

# Update packages
apt-get update

# Install package dependencies
apt-get install -y curl unzip apt-transport-https ca-certificates gnupg lsb-release

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip /tmp/awscliv2.zip -d /tmp
/tmp/aws/install

# Install kubectl
mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubectl
apt-mark hold kubectl

# Install jq
apt-get install -y jq

# Configure kubeconfig for the ubuntu user
mkdir -p /home/ubuntu/.kube
chown ubuntu:ubuntu /home/ubuntu/.kube

# Example helper script for ubuntu user
cat <<'EOF' > /home/ubuntu/update-kubeconfig.sh
#!/bin/bash
set -e
aws eks update-kubeconfig --region <region> --name <cluster-name> --alias <cluster-alias>
EOF

chmod +x /home/ubuntu/update-kubeconfig.sh
chown ubuntu:ubuntu /home/ubuntu/update-kubeconfig.sh