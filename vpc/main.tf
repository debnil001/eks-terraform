#create VPC
resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr_block
    enable_dns_support = true
    enable_dns_hostnames = true

    tags ={
        Name = "${var.cluster_name}-vpc"
        "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    }
}
#create private subnets accross availability zones
resource "aws_subnet" "private_subnet" {
    count = length(var.private_subnet_cidrs)
    vpc_id =aws_vpc.main.id
    cidr_block = var.private_subnet_cidrs[count.index]
    availability_zone = var.availability_zones[count.index]


    tags = {
        Name = "${var.cluster_name}-private-subnet-${count.index + 1}"
        "kubernetes.io/cluster/${var.cluster_name}" = "shared" 
        "kubernetes.io/role/internal-elb" = "1"                
    }
}
#ceate public subnets accross availability zones
resource "aws_subnet" "public_subnet" {
    count = length(var.public_subnet_cidrs)
    vpc_id= aws_vpc.main.id
    cidr_block = var.public_subnet_cidrs[count.index]
    availability_zone = var.availability_zones[count.index]

    map_public_ip_on_launch = true

    tags = {
        Name = "${var.cluster_name}-public-subnet-${count.index + 1}"
        "kubernetes.io/cluster/${var.cluster_name}" = "shared"
        "kubernetes.io/role/elb" = "1"
    }
}
#create internet gateway
resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "${var.cluster_name}-igw"
    }
}
#create public route table and attach the internet gateway and to public route table 
resource "aws_route_table" "public_route_table" {
    vpc_id=aws_vpc.main.id

    route {
        cidr_block="0.0.0.0/0"
        gateway_id=aws_internet_gateway.main.id
    }

    tags = {
        Name = "${var.cluster_name}-public-route-table"
    }
}
#associate the public subnets with public route table
resource "aws_route_table_association" "public_route_table_association" {
    count = length(var.public_subnet_cidrs)
    subnet_id = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public_route_table.id
}
#create elastic IPs in public subnets for NAT gateways
resource "aws_eip" "nat" {
    count = length(var.public_subnet_cidrs)
    domain = "vpc"
    tags = {
        Name = "${var.cluster_name}-nat-eip-${count.index + 1}"
    }
}
#create NAT gateways in public subnets and associate with elastic IPs
resource "aws_nat_gateway" "main" {
    count = length(var.public_subnet_cidrs)
    allocation_id = aws_eip.nat[count.index].id
    subnet_id = aws_subnet.public[count.index].id
    tags = {
        Name = "${var.cluster_name}-nat-gateway-${count.index + 1}"
    }
}
#create private route tables and associate with NAT gateways
resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.main[count.index].id
    }

    tags = {
        Name = "${var.cluster_name}-private-${count.index+1}"
    }
}
#associate the private subnets with private route tables
resource "aws_route_table_association" "private_route_table_association" {
    count = length(var.private_subnet_cidrs)
    subnet_id = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.private_route_table[count.index].id
}