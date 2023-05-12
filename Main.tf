terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">2.1"
    }
  }
}
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_vpc" "sapphire-vpc-1" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "sapphire-vpc"
  }
}

resource "aws_subnet" "sapphire-subnet-ubuntu" {
  vpc_id            = aws_vpc.sapphire-vpc-1.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = var.availability-zone-1

  tags = {
    Name = "Sapphire-subnet-ubuntu"
  }
}

resource "aws_subnet" "sapphire-subnet-redhat" {
  vpc_id            = aws_vpc.sapphire-vpc-1.id
  cidr_block        = "192.168.2.0/24"
  availability_zone = var.availability-zone-2

  tags = {
    Name = "Sapphire-subnet-redhat"
  }
}
resource "aws_security_group" "expose-ssh-tomcat" {
  name        = "expose-ssh-tomcat"
  description = "Allow ssh and tomcat inbound traffic"
  vpc_id      = aws_vpc.sapphire-vpc-1.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   # cidr_blocks = [aws_vpc.sapphire-vpc-1.cidr_block]
  }
  ingress {
    description = "exposing port for tomcat from VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.sapphire-vpc-1.cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "exposing port 22 for SSh and port 8080 for tomcat"
  }
}

resource "aws_security_group" "expose-tomcat" {
  name        = "expose-tomcat"
  description = "Allow  tomcat inbound traffic"
  vpc_id      = aws_vpc.sapphire-vpc-1.id


  ingress {
    description = "exposing port for tomcat from VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.sapphire-vpc-1.cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "exposing port 8080 for tomcat"
  }
}

resource "aws_instance" "web-ubuntu" {
  depends_on                  = [aws_security_group.expose-ssh-tomcat]
  ami                         = var.ami-1
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.sapphire-subnet-ubuntu.id
  security_groups             = [aws_security_group.expose-ssh-tomcat.id]
  associate_public_ip_address = true
  key_name                    = "techbleat-ket"

  tags = {
    Name = "ubuntu"
  }
}

resource "aws_instance" "web-redhat" {
  depends_on                  = [aws_security_group.expose-tomcat]
  ami                         = var.ami-2
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.sapphire-subnet-redhat.id
  security_groups             = [aws_security_group.expose-tomcat.id]
  associate_public_ip_address = true
  key_name                    = "techbleat-ket"

  tags = {
    Name = "redhat"
  }
}