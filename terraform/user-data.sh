#!bin/bash
export AWS_ACCESS_KEY_ID="${$AWS_ACCESS_KEY}"
export AWS_SECRET_ACCESS_KEY_ID="${$AWS_SECRET_ACCESS_KEY}"
export AWS_DEFAULT_REGION="${AWS_REGION}"

sudo apt update -y
sudo apt install -y docker
sudo usermod -a -G docker ec2-user
newgrp docker

sudo systemctl enable docker.service
sudo systemctl start docker.service

