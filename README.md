# sre-movierama

- using gitignore.io to generate the .gitignore (terraform and go template)
- setting up web app and postgres db in docker containers
- terraform -> kubernetes cluster pattern (??)

Current plan:
Using Terraform and EC2 Instances:
   - Provision EC2 instances using Terraform to create a cluster of virtual machines on AWS.
   - Install and configure MongoDB directly on these EC2 instances.
   - Establish replication and sharding within the MongoDB cluster.

AWS: {
    - IAM user with permissions {
        * AdministratorAccess
        * AmazonEC2FullAccess
        * IAMFullAccess
    }
    - Using the AWS cli
    - configs {
        * default region: eu-central-1
        * output format: json
    }
    - instance info {
        Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2023-05-16
        type: t2.micro
    }
}

Terraform: {
    1: terraform init -> initialize backend
    2: terraform plan -> show what currently exists vs what we have setup
    3: terraform apply -> "commit" to the plan
    4: terraform destroy -> "destroy" instance so we dont waste resources
}

Misc information {
    - Kubernetes Operator doesn’t support arbiter nodes.
    - We could skip the arbiter and have just 2 secondaries (??)
}