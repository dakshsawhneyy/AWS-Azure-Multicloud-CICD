# ECR Repo
resource "aws_ecr_repository" "app" {
  name = "${var.app_name}-repo"
}


# Create AWS Security Group
resource "aws_security_group" "web_sg" {
  name        = "${var.app_name}-sg"
  description = "Allow SSH and HTTP traffic"

  # Allow Inbound HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Inbound SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow All Outbound Traffic (Crucial for pulling from ECR)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# EC2 Instance
resource "aws_instance" "web" {
  ami           = "ami-01a00762f46d584a1"
  instance_type = "t3.micro"
  key_name      = "demo-key-pair"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  tags = {
    Name = "${var.app_name}-vm"
  }
}