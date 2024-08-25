#!/bin/bash
# root 계정으로 전환 후 초기 로그 기록 파일 생성
sudo su
cd ~
echo "" >> /root/initial_logs.txt

sudo yum update -y && echo "yum update success" >> /root/initial_logs.txt || echo "yum update failed" >> /root/initial_logs.txt


# cronie를 설치함
sudo yum install cronie -y && echo "cronie install success" >> /root/initial_logs.txt || echo "cronie install failed" >> /root/initial_logs.txt

# terraform을 설치함
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform && echo "terraform install success" >> /root/initial_logs.txt || echo "terraform install failed" >> /root/initial_logs.txt

# Docker를 설치함
sudo yum install -y git && echo "git install success" >> /root/initial_logs.txt || echo "git install failed" >> /root/initial_logs.txt
sudo yum install docker -y && echo "docker install success" >> /root/initial_logs.txt || echo "update install failed" >> /root/initial_logs.txt
sudo service docker start && echo "docker start success" >> /root/initial_logs.txt || echo "docker start failed" >> /root/initial_logs.txt
sudo chkconfig docker on

# Docker-Compose를 설치함
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose && echo "docker-compose install success" >> /root/initial_logs.txt || echo "docker-compose install failed" >> /root/initial_logs.txt
sudo chmod +x /usr/local/bin/docker-compose
sudo systemctl daemon-reload

# S3에서 Terraform, locust 코드가 포함된 파일을 다운로드
sudo aws s3 cp s3://lsh-dev-ecom-test-s3-2/terraform_code/ /root/terraform_code/ --recursive  && echo "code import from s3" >> /root/initial_logs.txt || echo "code import from failed" >> /root/initial_logs.txt

# locust 환경을 구축함
sudo mkdir /mnt/locust
sudo cp /root/terraform_code/locust/locustfile.py /mnt/locust/locustfile.py  && echo "locustfile move success" >> /root/initial_logs.txt || echo "locustfile move failed" >> /root/initial_logs.txt
#docker-compose up -f /root/terraform_code/locust/docker-compose.yaml -d && echo "docker-compose up success" >> /root/initial_logs.txt || echo "locustfile move failed" >> /root/initial_logs.txt

# Create variables for the cron jobs
sudo chmod 500 /root/terraform_code/sourceCode/create.sh
sudo chmod 500 /root/terraform_code/sourceCode/delete.sh

# Backup existing crontab
sudo crontab -l > /root/mycron.bak

# Add new cron jobs to the backup file
CREATE_JOB="0 6 * * * sh /root/terraform_code/sourceCode/create.sh > /root/create.log 2>&1"
DESTROY_JOB="0 20 * * * sh /root/terraform_code/sourceCode/delete.sh > /root/destroy.log 2>&1"
sudo echo "$CREATE_JOB" >> /root/mycron.bak
sudo echo "$DESTROY_JOB" >> /root/mycron.bak

# Install the new cron jobs from the updated crontab file
crontab /root/mycron.bak

# Verify that the crontab has been updated
echo "New cron jobs have been added."
crontab -l