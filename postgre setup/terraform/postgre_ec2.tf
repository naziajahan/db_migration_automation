provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "this" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.1.0/24"
}

resource "aws_security_group" "this" {
  name        = "postgresql_sg"
  description = "Allow PostgreSQL traffic"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_instance" "postgre_instance" {
  ami           = data.aws_ami.amazon_linux_2.id 
  instance_type = "t2.micro"
  subnet_id = aws_subnet.this.id

  vpc_security_group_ids = [aws_security_group.this.id]

  key_name = "path/to/vault/key"

  tags = {
    Name = "postgresql-instance"
  }
}

output "postgres_instance_public_ip" {
  value = aws_instance.this.public_ip
}
