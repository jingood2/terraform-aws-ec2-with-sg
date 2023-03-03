# Generic Variables
# Input Variables
# AWS Region
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
  default     = "ap-northeast-2"
}
# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type        = string
  default     = "dev"
}
# Business project
variable "project" {
  description = "project or department in the large organization this Infrastructure belongs"
  type        = string
  #default = "sales"
  default = "jingood2"
}

####################################################################

# Define Local Values in Terraform
locals {
  owners      = var.project
  environment = var.environment
  name        = "${var.project}-${var.environment}"
  #name = "${local.owners}-${local.environment}"
  common_tags = {
    owners      = local.owners
    environment = local.environment
  }

  userdata = <<-USERDATA
  [settings]
  motd = "Beware!, you are monitored!"
  USERDATA
}
