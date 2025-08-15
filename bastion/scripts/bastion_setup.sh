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
KUBECTL_VERSION=$(curl -s https://dl.k8s.io/release/stable.txt)
curl -LO https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

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