
# https://github.com/hashicorp/terraform-provider-aws

# Configure the AWS Provider
provider "aws" {
  region = "sa-east-1"
}

variable "region" {
  description = "region"
  type        = string
  default     = "sa-east-1"
}