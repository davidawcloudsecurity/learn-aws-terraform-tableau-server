# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Define Variables
variable "region" {
  default = "us-east-1"
}

variable setup_filename {
  default = "setup_tableau_server.sh"
}

variable "ami" {
  default = "ami-0c798d4b81e585f36" # Microsoft Windows 2022 Datacenter edition.
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

# Create Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.10.0/24"
  availability_zone = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# Create Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create Security Group
resource "aws_security_group" "public_security_group" {
  name        = "allow_80_443"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
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

  tags = {
    Name = "allow_80_443"
  }
}

# Create IAM Role for EC2 Instance
resource "aws_iam_role" "ec2_session_manager_role" {
  name = "ec2_session_manager_role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

# Attach IAM Policy for Session Manager
resource "aws_iam_role_policy_attachment" "session_manager_policy" {
  role       = aws_iam_role.ec2_session_manager_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create Instance Profile for the Role
resource "aws_iam_instance_profile" "ec2_session_manager_profile" {
  name = "ec2_session_manager_profile"
  role = aws_iam_role.ec2_session_manager_role.name
}

# Launch EC2 Instance with Session Manager
resource "aws_instance" "windows2022_instance" {
  ami                    = var.ami
  instance_type          = "m5.2xlarge"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.public_security_group.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_session_manager_profile.name

  metadata_options {
    http_tokens = "required"
    http_endpoint = "enabled"
  }

  root_block_device {
    volume_size = 50
    volume_type = "gp2"
  }

  # Example PowerShell script saved as setup_tableau_server.ps1
  user_data = <<-EOF
  <script>
  mkdir c:\temp
  cd c:\temp
  curl -LO "https://downloads.tableau.com/esdalt/2024.2.10/TableauServer-64bit-2024-2-10.exe"
  start /wait TableauServer-64bit-2024-2-10.exe /silent ACCEPTEULA=1 ACTIVATIONSERVICE='1'  
  </script>
  EOF

  tags = {
    Name = "tableau server"
  }
}
