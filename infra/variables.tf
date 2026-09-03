variable "aws_region" {
  default = "ap-south-1"
}

variable "app_name" {
  default = "multicloud-pipeline"
}

variable "resource_group_name" {
  default = "multicloud-rg"
}

variable "azure_location" {
  default = "Central India"
}

variable "azure_vm_ssh_public_key" {
  type      = string
  sensitive = true
}