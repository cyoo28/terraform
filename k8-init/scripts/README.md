## Setting up
Lines 1-3: Ensure that the script fails fast and safely.
Lines 4-16: Retrieve the EC2 instance private DNS and IP. Then set the host name of the instance to the private DNS.
Lines 17-20: Disable swap and prevent the instance from re-enabling swap on reboot. This is because Kubernetes expects consistent memory behavior.
Lines 21-29: Enable kernel modules. overlay file system for containerd and br_netfilter for pod networking.
Lines 30-36: Create a configuration file for kernel behavior. This passes bridged traffic to iptables and enables IP forwarding.
Lines 37-39: Update kernel behavior without rebooting.
## Installing Kubernetes Components
Lines 40-53: Install and configure containerd. This generates the default containerd config and adjusts it to use the systemd cgroups.
Lines 54-62: Install Kubernetes tools: kubelet, kubeadm, and kubectl.
Lines 63-81: Install and configure ecr-credential-provider. This tells kubelet to use ecr-credential-provider to get credentials to fetch ECR images.
## Initializing Kubernetes
Lines 82-107: Configure kubernetes. Set the cloud provider to external to use the AWS cloud controller.
Lines 108-115: Initialize the cluster with our configuration. Here we also allow the ubuntu user to run kubectl commands.
## Creating Additional Scripts and finishing up
Lines 116-128: Create a script for creating a join command for the worker nodes to join the cluster. Make it executable.
Lines 129-143: Create a script for installing AWS cloud provider and Weave Net. Make it executable.
Lines 144-215: Create a script for installing kube2iam. Make it executable.
Lines 216-217: Enable kubelet on restart and restart the instance.
