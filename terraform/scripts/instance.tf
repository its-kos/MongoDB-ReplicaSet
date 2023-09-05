resource "aws_instance" "mongodb_instance" {
    count = 3 
    ami = "ami-04e601abe3e1a910f" // Canonical, Ubuntu, 22.04 LTS
    instance_type = "t2.micro"
    availability_zone = "eu-central-1a"
    tags = {
        Name = "mongodb-${count.index}"
    }
}