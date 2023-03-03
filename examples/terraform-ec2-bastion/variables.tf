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

variable "instance_type" {
  type        = string
  description = "Instance type"
  default = "t3.micro"
}

variable "vpc_id" {
  type        = string
  description = "vpc id"
}

variable "enable_sshkey" {
  description = "enable SSH Key to be created"
  type        = bool
  default     = false
}

variable "key_name" {}

variable "working_dir" {}
/* variable "multi_instances" {
  description = "A map of ec2 instances containing their properties and configurations"
  type        = any
  default     = {}
} */
