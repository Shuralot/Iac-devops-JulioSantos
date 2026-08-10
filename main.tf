terraform {
  backend "s3" {
    bucket       = "terraform-state-cesar-julio-2026"
    key          = "atividade1/terraform.tfstate"
    region       = "sa-east-1"
    use_lockfile = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name     = "vpc-${terraform.workspace}"
    Curso    = "Pós-graduação DevOps - CESAR School"
    Ambiente = terraform.workspace
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 1)
  map_public_ip_on_launch = true

  tags = {
    Name     = "subnet-publica-${terraform.workspace}"
    Curso    = "Pós-graduação DevOps - CESAR School"
    Ambiente = terraform.workspace
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name     = "igw-${terraform.workspace}"
    Curso    = "Pós-graduação DevOps - CESAR School"
    Ambiente = terraform.workspace
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name     = "rt-publica-${terraform.workspace}"
    Curso    = "Pós-graduação DevOps - CESAR School"
    Ambiente = terraform.workspace
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

module "web_server" {
  source = "./modules/web-server"

  vpc_id        = aws_vpc.main.id
  subnet_id     = aws_subnet.public.id
  meu_ip        = var.meu_ip
  ambiente      = terraform.workspace
  instance_type = terraform.workspace == "prod" ? "t3.micro" : "t2.micro"
}