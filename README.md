# Movierama Assignment



## Table of Contents

- [Movierama Assignment](#movierama-assignment)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
    - [Prerequisites](#prerequisites)
    - [Installation](#installation)
      - [For Linux:](#for-linux)
      - [For Windows:](#for-windows)
  - [Getting Started](#getting-started)
  - [Usage](#usage)
  - [Configuration](#configuration)
  - [Deployment](#deployment)
  - [Monitoring](#monitoring)

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

## Getting Started

To set up the 

## Usage

Explain how to use your project. Provide examples and usage scenarios. Include any important commands, API endpoints, or interfaces that users should be aware of.

## Configuration

Explain the configuration options available for your project. Provide guidance on how to customize and configure your DevOps setup for different use cases.

## Deployment

Describe the deployment process. Include deployment scripts, tools, or platforms that can be used. If applicable, provide guidance on scaling and managing deployments.

## Monitoring

Explain how to monitor the health and performance of your DevOps setup. Mention any monitoring tools, metrics, or dashboards that users can use to keep an eye on their deployments.
