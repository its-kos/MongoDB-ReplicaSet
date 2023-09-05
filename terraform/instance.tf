resource "aws_instance" "mongo-instance" {
    ami               = "ami-04e601abe3e1a910f"
    availability_zone = "eu-central-1a"
    instance_type     = "t2.micro"
    count             = "3"
    subnet_id         = aws_subnet.private_subnet.id
    security_groups   = [aws_security_group.mongo_security_group.id]
    # associate_public_ip_address = true
    user_data         = "${file("script.sh")}"
    tags = {
        Name = "$mongo-${count.index + 1}"
    }
}

resource "aws_instance" "bastion-instance" {
    ami               = "ami-04e601abe3e1a910f"
    availability_zone = "eu-central-1a"
    instance_type     = "t2.micro"
    count             = "1"
    subnet_id         = aws_subnet.public_subnet.id
    security_groups   = [aws_security_group.bastion_security_group.id]
    user_data         = "${file("app-script.sh")}"
    depends_on        = [aws_internet_gateway.main_gw]
    tags = {
        Name = "bastion"
    }
}

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