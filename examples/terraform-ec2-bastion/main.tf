
data "aws_vpc" "default" {
  default = true
}

module "ec2-bastion" {
  source = "../.."

  instance_type = var.instance_type
  vpc_id = var.vpc_id
  enable_sshkey = var.enable_sshkey
  key_name = var.key_name
  working_dir = var.working_dir
}
