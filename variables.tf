variable "instance_type" {
}

variable "vpc_id" {
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
