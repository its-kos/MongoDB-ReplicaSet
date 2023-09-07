resource "aws_instance" "mongo_instance" {
    ami               = "ami-0766f68f0b06ab145" # Amazon Linux 2023
    # availability_zone = "eu-central-1a"
    instance_type     = "t2.micro"
    count             = "3"
    subnet_id         = aws_subnet.public_subnet.id
    vpc_security_group_ids = ["${aws_security_group.mongo_sg.id}"]
    tags = {
        Name = "mongodb-${count.index}"
    }

    # provisioner "local-exec" {
    #     working_dir = "${path.module}/../ansible/"
    #     command = "ansible-playbook -i '${join(",", aws_instance.mongodb[*].public_ip)}' mongodb.yml"
    # }
}

resource "aws_instance" "app_instance" {
    ami           = "ami-0766f68f0b06ab145" # Replace with your desired AMI
    instance_type = "t2.micro"
    subnet_id     = aws_subnet.public_subnet.id
    tags = {
        Name = "app-instance"
    }
}

resource "aws_security_group" "mongo_sg" {
    vpc_id = aws_vpc.main_vpc.id

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [aws_vpc.main_vpc.cidr_blocks]
    }

    ingress {
        from_port   = 27017
        to_port     = 27017
        protocol    = "tcp"
        cidr_blocks = [aws_vpc.main_vpc.cidr_blocks]
    }

    ingress {
        from_port   = -1
        to_port     = -1
        protocol    = "icmp"
        cidr_blocks = [aws_vpc.main_vpc.cidr_blocks]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "app_sg" {
    vpc_id = aws_vpc.main_vpc.id

    ingress {
        from_port   = 22 // SSH
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 443 // https
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# resource "aws_instance" "bastion-instance" {
#     ami                         = "ami-0766f68f0b06ab145"
#     instance_type               = "t2.micro"
#     key_name                    = "${var.key_name}"
#     subnet_id                   = aws_subnet.public_subnet.id
#     associate_public_ip_address = true
#     user_data                   = "${data.template_file.userdata.rendered}"
#     vpc_security_group_ids      = [aws_security_group.jumpbox_sg.id]

#     tags = {
#         Name = "bastion-host"
#     }

#     root_block_device {
#         volume_type = "standard"
#     }

#     provisioner "file" {
#         source      = "~/.ssh/id_rsa"
#         destination = "/home/ec2-user/id_rsa"

#         connection {
#             type         = "ssh"
#             user         = "ec2-user"
#             host         = "${self.public_ip}"
#             agent        = false
#             private_key  = "${file("~/.ssh/id_rsa")}"
#         }
#     }
# }

# data "template_file" "ec2ud" {
#     template = file("user-data.sh")
# }


# resource "aws_security_group" "jumpbox_sg" {
#     vpc_id = aws_vpc.main_vpc.id

#     ingress {
#         from_port   = 22
#         to_port     = 22
#         protocol    = "tcp"
#         cidr_blocks = ["0.0.0.0/0"]
#     }

#     egress {
#         from_port   = 0
#         to_port     = 0
#         protocol    = "-1"
#         cidr_blocks = ["0.0.0.0/0"]
#     }
# }


# data "aws_iam_policy_document" "instance-assume-role-policy" {
#     statement {
#         actions = ["sts:AssumeRole"]

#         principals {
#             type        = "Service"
#             identifiers = ["ec2.amazonaws.com"]
#         }
#     }
# }

# resource "aws_iam_role" "mongo-role" {
#     name               = "mongo_role"
#     path               = "/system/"
#     assume_role_policy = "${data.aws_iam_policy_document.instance-assume-role-policy.json}"
# }

# resource "aws_iam_instance_profile" "mongo-instance-profile" {
#     name = "mongo-instance-profile"
#     role = "${aws_iam_role.mongo-role.name}"
# }

# resource "aws_iam_role_policy" "ec2-describe-instance-policy" {
#     name = "ec2-describe-instance-policy"
#     role = "${aws_iam_role.mongo-role.id}"

#     policy = <<EOF
#     {
#         "Version": "2012-10-17",
#         "Statement": [
#             {
#                 "Effect": "Allow",
#                 "Action": [
#                     "ec2:DescribeInstances",
#                     "ec2:DescribeTags"
#                 ],
#                 "Resource": "*"
#             }
#         ]
#     }
#     EOF
# }

# // Keys to use with Ansible
# resource "tls_private_key" "key" {
#     algorithm = "RSA"
# }

# resource "aws_key_pair" "aws_key" {
#     key_name = "ansible-ssh-key"
#     public_key = tls_private_key.key.public_key_openssh
# }

# resource "aws_instance" "app-instance" {
#     ami               = "ami-04e601abe3e1a910f"
#     availability_zone = "eu-central-1a"
#     instance_type     = "t2.micro"
#     count             = "1"
#     subnet_id         = aws_subnet.private_subnet.id
#     security_groups   = [aws_security_group.app_security_group.id]
#     user_data         = "${file("app-script.sh")}"
#     depends_on        = [aws_internet_gateway.main_gw]
#     tags = {
#         Name = "app"
#     }
# }