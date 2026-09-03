terraform {
  backend "s3" {
    bucket       = "multicloud-cicd-statefile-55"
    region       = "ap-south-1"
    key          = "multicloud/terraform.tfstate"
    use_lockfile = true
  }
}