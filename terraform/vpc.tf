// Create the VPC
resource "aws_vpc" "main_vpc" {
    cidr_block = "10.0.0.0/16"
}

// Create the gateway to the internet
resource "aws_internet_gateway" "main_gw" {
    vpc_id = aws_vpc.main_vpc.id
}

// Create Main public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1a" 
}

// Create public Route Table
resource "aws_route_table" "public_routing_table" {
    vpc_id = aws_vpc.main_vpc.id
    route {
        cidr_block = "0.0.0.0/0" // Sends all IPv4 traffic to Gateway
        gateway_id = aws_internet_gateway.main_gw.id
    }
}

// Associating public subnet with route table
resource "aws_route_table_association" "public_association" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_routing_table.id
}

// Create Main private Subnet
resource "aws_subnet" "private_subnet" {
    vpc_id                  = aws_vpc.main_vpc.id
    cidr_block              = "10.0.2.0/24"
    availability_zone       = "eu-central-1a" 
}

// Create private Route Table
resource "aws_route_table" "private_routing_table" {
    vpc_id = aws_vpc.main_vpc.id
    route {
        cidr_block = "0.0.0.0/0" // Sends all IPv4 traffic to Gateway
        gateway_id = aws_internet_gateway.main_gw.id
    }
}

// Associating private subnet with route table
resource "aws_route_table_association" "private_association" {
    subnet_id = aws_subnet.private_subnet.id
    route_table_id = aws_route_table.private_routing_table.id
}


// Security Group for mongoDB cluster
resource "aws_security_group" "mongo_security_group" {
    vpc_id = aws_vpc.main_vpc.id

    ingress {
        from_port   = 22 // SSH
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 27017 //  port for MongoDB
        to_port     = 27017
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # ingress {
    #     from_port   = 27019 // is used by MongoDB to manage communication between servers.
    #     to_port     = 27019
    #     protocol    = "tcp"
    #     cidr_blocks = ["0.0.0.0/0"]
    # }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

// Security Group for bastion instance
resource "aws_security_group" "bation_security_group" {
    vpc_id = aws_vpc.main_vpc.id

    # IMPORTANT -> TODO
    ingress {
        from_port   = 22 // SSH
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port       = 443 // https for the app endpoints
        to_port         = 443
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    egress {
        from_port       = 0
        to_port         = 65535
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}

// Creating an elastic IP, i.e. a public IP
resource "aws_eip" "main_eip" {
    domain = "vpc"
    count    = "3"
    instance = "${element(aws_instance.mongo-instance.*.id, count.index)}"
}