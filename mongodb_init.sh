#!/bin/bash

cd terraform/

# Step 1: Initialize Terraform
terraform init

# Step 2: Apply Terraform configuration to create AWS resources (-auto-approve flag to save typing "yes")
terraform apply -auto-approve

# Extract the public IP addresses of MongoDB and the web app instances
# And create an Ansible inventory file
mongodb_ips=$(terraform output -json | jq -r '.mongo_public_ips.value[]')
go_web_ips=$(terraform output -json | jq -r '.app_public_ip.value[]')

echo "[mongodb]" > ansible/inventory.ini
for ip in $mongodb_ips; do
    echo "$ip ansible_ssh_user=ec2-user" >> ansible/inventory.ini
done

echo "[goweb]" >> ansible/inventory.ini
for ip in $go_web_ips; do
    echo "$ip ansible_ssh_user=ec2-user" >> ansible/inventory.ini
done

# Step 3: Run Ansible playbook to configure MongoDB replica set
ansible-playbook -i ansible/inventory.ini mongodb.yml

# Connect to one MongoDB instance to initialize the replica set
first_mongodb_instance=$(echo $mongodb_ips | awk '{print $1}')
ssh ec2-user@$first_mongodb_instance "mongo --eval 'rs.initiate()'"