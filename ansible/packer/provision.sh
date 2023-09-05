#!/bin/bash -e
export playbook=$1
sudo apt upgrade -y
sudo apt update
sudo apt install software-properties-common -y
sudo apt-add-repository ppa:ansible/ansible
sudo apt update
sudo apt install ansible -y
cd /var/tmp
sudo ansible-playbook -i "localhost," -c local $playbook