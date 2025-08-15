# Terraform
This repo contains my terraform directories that I use for various projects in AWS. You can read a description of these projects below:

## bastion
This directory is used to create bastion hosts used to connect to the eks cluster created by the eks directory. This is necessary because the eks api is set to private and can only be accessed from within the vpc.

## docker
This directory is used to create an EC2 instance that is capable of running Docker.

## eks
This directory is used to create an Elastic Kubernetes Service (EKS) cluster. It includes the cluster itself as well as add-ons to the cluster.

## genai-webapp
This directory is used to create an IAM role that is needed to run my generative AI web application. [You can view that project here.](https://github.com/cyoo28/genai-demo)

## k8-init and k8-asg
These terraform directories are used for my Kubernetes self-managed cluster project. k8-init is used to initialize the cluster by creating and configuring a control plane EC2 instance. It also creates a corresponding security group, IAM instance profile, and configures the EC2 instance using a userdata script. k8-asg sets up an autoscaling group of worker node EC2 instances that join the cluster. Like k8-init, this terraform directory also creates a corresponding security group, IAM instance profile, and configures an EC2 launch template that includes a userdata script. Between these 2 directories, a self-managed Kubernetes cluster can be provisioned in AWS.

## modules
This directory contains Terraform modules.  The ec2 module is a module for an EC2 instance and is referenced in docker and k8-init. The asg module is a module for an auto-scaling group and is referenced in k8-asg.
