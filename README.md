# Movierama Assignment



## Table of Contents

- [Movierama Assignment](#movierama-assignment)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
    - [Prerequisites](#prerequisites)
    - [Installation](#installation)
      - [For Linux:](#for-linux)
      - [For Windows:](#for-windows)
  - [Usage](#usage)
  - [Configuration](#configuration)
  - [Assignment Section](#assignment-section)
  - [Issues](#issues)
  - [Compromises](#compromises)
  - [Things not completed](#things-not-completed)

## Overview

This project aims to create infrastructure for a microservice. Specifically a replicated mongoDB cluster, and an accompanying sample web app to act as a blueprint upon which a normal app can be built. It uses Terraform and Ansible to automatically provision and configure the required infrastructure pieces on AWS, and a Go backend sample app that pings the mongoDB cluster for health and relevant metrics.

The entire deployment is done on EC2 machines of AWS, inside a custom VPC. The architecture is shown below.


A more secure architecture like the one shown below was not chosen due to it being more complex than needed however it is certainly a more robust one.


### Prerequisites

For now, this project works best in a Linux/macOS environment as it requires bash to run the startup script and Ansible is not officially supported on Windows. If you are on Windows, [install WSL](https://learn.microsoft.com/en-us/windows/wsl/install) and follow the same steps. 

This project uses [Terraform](https://developer.hashicorp.com/terraform/downloads?ajs_aid=406e18d1-b747-4153-bf58-60f840b3f37e&product_intent=terraform) and [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html). This means you need to have both tools installed and added to PATH.

The tool [JQ](https://jqlang.github.io/jq/) is also used in the *mongodb_init.sh* script to extract IPs from terraform output. To install it:
```
$ sudo apt install jq
```
If you don't want to use it, run the steps in the script on your own and manually create the *inventory.ini* file in the **Ansible** directory in the following format:
```
[mongodb]
<Public IP of first mongodb machine> ansible_ssh_user=ec2-user
<Public IP of second mongodb machine> ansible_ssh_user=ec2-user
<Public IP of third mongodb machine> ansible_ssh_user=ec2-user
[goweb]
<Public IP of the go app machine> ansible_ssh_user=ec2-user
```

Also an AWS account is requied and preferably an IAM user in a User group with the permissions:

* AdministratorAccess
* AmazonEC2FullAccess

Then, keep note of the User's **AWS Access Key** and **AWS Secret Key** and replace the following lines
```
access_key = var.aws_access_key
secret_key = var.aws_secret_key
```
with 
```
access_key = <Your Access Key here>
secret_key = <Your Secret Key here>
```
in the *proviver.tf* file. Make sure to keep these keys safe as they can be used to access your account. Do not push them in any public repo. Also, delete the *variables.tf* file.

### Installation

#### For Linux:

```
$ git clone https://github.com/its-kos/sre-movierama.git
$ cd sre-movierama
$ sudo chmod +x mongodb_init.sh
$ sudo chmod +x mongodb_dest.sh
```
then run either
```
$ ./mongodb_init.sh
```
to run the script that sets up the infrastructure and deploys the app.
Or
```
$ ./mongodb_dest.sh
```
to tear everything down and remove all instances from AWS. (Keep in mind that since this is hosted on AWS, if you leave the deployment up and runnig it could cause unwanted costs)

#### For Windows:
Do note that Ansible does not support a Windows control node. WSL is needed so set WSL up and follow the above steps.

## Usage

After the infrastructure has been provisioned and deployed, you can use and develop the web app to your liking. The app has 2 endpoints 

1) /health - This endpoint checks if the cluster is up and running and replies accordingly
2) /metrics - This endpoint replies with metrcis in the Prometheus format.

By developing this app you can interact with the mongoDB cluster.

## Configuration

There are a few options of configuring this project. Most of the configuration happens in the **Terraform** directory. There you can change the region of deployment in the *provider.tf* script. Then in the *instance.tf* script you can change the inbound and outbound rules for your security groups as well as information about the instances.

In the **Ansible** directory and in the *go-app.yml* and *mongodb.yml* files you can modify the configuration of the machines for example to add more users to the mongoDB cluster.

## Assignment Section

## Issues
Right now, I can't get Ansible to connect via SSH to the hosts and configure them. Scripts seem ok, I unfortunately don't know enough about Ansible to properly debug this. I assume the AWS instnaces would require SSH setup. Everything else runs ok.

Also, I can't figure out how to make JQ parse a single IP string. It works fine for the array of IPs that come from the mongoDB machines however I keep getting an error when trying to parse the single IP coming from the go web instance. I assume it's overkill or it can be done without JQ however from my understanding JQ is a normal practise for extracting IPs form JSON and I found it in most docs so I went with it.

## Compromises

As mentioned in the overview a few compromises had to be made. 

1) I opted to go with the free tier of AWS and not something like Vagrant and Kubernetes so an AWS account is required.
2) I opted for a less secure architecture due to complexity. Everything is in a public subnet without a Bastion host separating them.
3) The deployment works only on either Linux or WSL since Ansible cannot work on a Windows host. It could be changed to accomodate for manual instance configuration without Ansible.

**Do note that I have kept all comments to showcase my thought process during development and the different ways I tried going about it. I would not normally leave all these comments**

## Things not completed
Due to knowledge and time contraints all the optional tasks are not completed and as mentioned the assignment is not 100% complete as I cannot get Ansible to connect via SSH and configure the machines. 

Regarding the optional tasks, for the external postgres db, I would probably set up another instance and configure postgres on it like the rest of the machines, then I assume a postgres driver like [this one](https://github.com/lib/pq) could be used to talk to the database (similarly to the mongoDB cluster driver). Then, similarly create an additional **/ready** endpoint to ping the database. Pretty similar to the mongoDB cluster's **/health** endpoint.

Regarding the prometheus / grafana stack, I didn't have enought time to research the stack so I am not sure / confident enought to say what I could have done.