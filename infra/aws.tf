# ECR Repo
resource "aws_ecr_repository" "app" {
  name = "${var.app_name}-repo"
}

# EC2 Instance
resource "aws_instance" "web" {
  ami           = "ami-01a00762f46d584a1"
  instance_type = "t3.micro"
  key_name      = "demo-key-pair"
  tags = {
    Name = "${var.app_name}-vm"
  }
}