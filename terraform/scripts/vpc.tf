// Create the VPC
resource "aws_vpc" "default_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "main-vpc"
    }
}

// Create the gateway to the internet
data "aws_internet_gateway" "default_gw" {
    vpc_id = aws_vpc.default_vpc.id
}

// Create Route Table
resource "aws_route_table" "default_routing_table" {
  route_table_id = aws_vpc.default_vpc.id
  route {
    cidr_block = "0.0.0.0/0" // Sends all IPv4 traffic to Gateway
    gateway_id = aws_internet_gateway.default_gw.id
  }
}

// Create Main Subnet
resource "aws_subnet" "default_subnet" {
  vpc_id                  = aws_vpc.default_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1a" 
}

// Associating subnet with route table
resource "aws_route_table_association" "default_routing_table_association" {
    subnet_id = aws_vpc.default_vpc.id
    route_table_id = aws_route_table.default_routing_table.id
}

// Creating the Network Interface
resource "aws_network_interface" "default_network_interface" {
    subnet_id = aws_subnet.default_subnet.id
    private_ip = ["10.0.1.50"] // We have to choose one or more that is not allocated by AWS ex. 10.0.1.1 etc.
}

// Creating an elastic IP, i.e. a public IP
resource "aws_eip" "default_eip" {
    vpc = true
    network_interface = aws_network_interface.default_network_interface.id // Assign it to our interface
    associate_with_private_ip = "10.0.1.50"
    depends_on = [data.aws_internet_gateway.default_gw]
}