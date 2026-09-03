output "ecr_repo_url" {
  value = aws_ecr_repository.app.repository_url
}

output "ec2_public_ip" {
  value = aws_instance.web.public_ip
}

output "acr_repo_url" {
  value = azurerm_container_registry.app.login_server
}

output "vm_public_ip" {
  value = azurerm_public_ip.web_public_ip.ip_address
}