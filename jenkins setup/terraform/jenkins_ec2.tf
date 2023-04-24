provider "aws" {
  region = "eu-central-1"
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

resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"

  key_name = "key_ec2" //name of the punlic key stored in aws key pair

  tags = {
    Name = "jenkins"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("${path.module}/key") //path to private key
    timeout     = "2m"
  }
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  description = "Allow inbound traffic to Jenkins"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "jenkins_eip" {
  vpc = true
  instance = aws_instance.jenkins.id
}

output "jenkins_public_ip" {
  value = aws_eip.jenkins_eip.public_ip
}
