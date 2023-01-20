# Demo-Waypoint

This repo contains a straightforward demo for Waypoint. Instructions for 
delivering this demo can be found below.

## Prerequisites

- AWS CLI
- Terraform version 1.3.x or higher
- kubectl CLI
- Waypoint installed on your machine

## Demo Setup

1. Clone this repo
   - `git clone ...`
1. Set AWS credentials
1. Build out the EKS Cluster (prepare to grab a coffee)
   - `cd tf-aws-eks`
   - `terraform init`
   - `terraform apply`
1. Update kubeconfig with new cluster info
   - `aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)`
1. Navigate to the above directory
   - `cd ..`
1. Set `KUBECONFIG` environment variable to the path of your kubeconfig
   - `export KUBECONFIG={path/to/kubeconfig}`
1. 