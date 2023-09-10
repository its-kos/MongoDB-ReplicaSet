#!/bin/bash

cd terraform/

# Step 1: Initialize Terraform
terraform init

# Step 2: Apply to create AWS resources (-auto-approve flag to save typing "yes")
terraform apply -auto-approve

# Extract the public IP addresses of MongoDB and the web app instances
# And create an Ansible inventory file
mongodb_ips=$(terraform output -json | jq -r '.mongo_public_ips.[]')
go_web_ip=$(terraform output -json | jq -r '.app_public_ip.value')

echo "[mongodb]" > ../ansible/inventory.ini
for ip in $mongodb_ips; do
    echo "$ip ansible_ssh_user=ec2-user" >> ../ansible/inventory.ini
done

echo "[goweb]" >> ansible/inventory.ini
echo "$go_web_ip ansible_ssh_user=ec2-user" >> ../ansible/inventory.ini

# Step 3: Run Ansible playbook to configure MongoDB replica set
# and go web app instance
cd ../ansible/
ansible-playbook -i inventory.ini mongodb.yml
ansible-playbook -i inventory.ini go-app.yml
