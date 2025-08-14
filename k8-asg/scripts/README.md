## Setting up
- Lines 1-3: Ensure that the script fails fast and safely.
- Lines 4-8: Set variables for the join command (that lets us join the Kubernetes cluster)
- Lines 9-18: Retrieve the EC2 instance private DNS and IP. Then set the host name of the instance to the private DNS.
- Lines 19-22: Disable swap and prevent the instance from re-enabling swap on reboot. This is because Kubernetes expects consistent memory behavior.
- Lines 23-31: Enable kernel modules. overlay file system for containerd and br_netfilter for pod networking.
- Lines 32-38: Create a configuration file for kernel behavior. This passes bridged traffic to iptables and enables IP forwarding.
- Lines 39-41: Update kernel behavior without rebooting.
## Installing Kubernetes Components
- Lines 42-55: Install and configure containerd. This generates the default containerd config and adjusts it to use the systemd cgroups.
- Lines 56-64: Install Kubernetes tools: kubelet, kubeadm, and kubectl.
- Lines 65-83: Install and configure ecr-credential-provider. This tells kubelet to use ecr-credential-provider to get credentials to fetch ECR images.
## Initializing Kubernetes
- Lines 84-98: Configure kubernetes. Set the cloud provider to external to use the AWS cloud controller.
- Lines 99-100: Initialize the cluster with our configuration.
## Finishing up
- Lines 101-102: Enable kubelet on restart and restart the instance.
