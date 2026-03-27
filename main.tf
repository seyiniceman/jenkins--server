terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "sf-proper"
    dynamodb_table = "app-state"
    key            = "LockID"
    region         = "eu-west-1"
    profile        = "Seyi"
  }
}

########################################
# PROVIDER
########################################
provider "aws" {
  region                   = "eu-west-1"
  shared_config_files      = ["/home/seyin/.aws/config"]
  shared_credentials_files = ["/home/seyin/.aws/credentials"]
  profile                  = "Seyi"
}

########################################
# DATA SOURCES
########################################
data "aws_availability_zones" "available_zones" {}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

########################################
# NETWORK
########################################
resource "aws_default_vpc" "default_vpc" {
  tags = {
    Name = "default-vpc"
  }
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]

  tags = {
    Name = "default-subnet"
  }
}

########################################
# SECURITY GROUP
########################################
resource "aws_security_group" "ec2_security_group" {
  name        = "jenkins-security-group"
  description = "Allow SSH, HTTP, Jenkins"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ⚠️ Restrict in production
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ⚠️ Restrict in production
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Alt HTTP"
    from_port   = 9090
    to_port     = 9090
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
    Name = "jenkins-sg"
  }
}

########################################
# KEY PAIR (FIXED PATH)
########################################
resource "aws_key_pair" "my_key" {
  key_name   = "sf_key"
  public_key = file("/home/seyin/.ssh/id_rsa.pub")
}

########################################
# EC2 INSTANCE
########################################
resource "aws_instance" "ec2_instance1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  subnet_id              = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  key_name               = aws_key_pair.my_key.key_name

  user_data = file("${path.module}/jenkins_install.sh")

  # 🔥 IMPORTANT: recreate instance when script changes
  user_data_replace_on_change = true

  tags = {
    Name = "Jenkins-server"
  }
}

########################################
# OUTPUT
########################################
output "jenkins_url" {
  description = "Access Jenkins UI"
  value       = "http://${aws_instance.ec2_instance1.public_ip}:8080"
}

output "public_ip" {
  value = aws_instance.ec2_instance1.public_ip
}
