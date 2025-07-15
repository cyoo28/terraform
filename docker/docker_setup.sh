#!/bin/bash
# Update all packages
dnf update -y

# Install Docker
dnf install -y docker

# Install Git
dnf install -y git

# Enable and start Docker service
systemctl enable --now docker

# Add ec2-user to docker group
usermod -aG docker ec2-user

# Reboot the instance
systemctl reboot