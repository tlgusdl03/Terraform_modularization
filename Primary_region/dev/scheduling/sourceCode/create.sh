#!/bin/bash
sudo su ec2-user

# Terraform 초기화 및 리소스 생성
cd /home/ec2-user/terraform_code/Primary_region/dev/infrastructure
terraform init
terraform apply -auto-approve