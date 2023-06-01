
#locals {
#  multi_instances = { for k, v in var.multi_instances : k => v if var.create }
#}


#############################################################
# Data sources to get VPC and default security group details
#############################################################
#data "aws_vpc" "this" {
#  filter {
#    key = "tag:Name"
#    values = ["${local.name}-*"]
#  }
#}

/* data "aws_security_group" "selected" {
  vpc_id = var.vpc_id

  filter {
    name   = "group-name"
    values = ["default"]
  }
}
 */



data "aws_security_group" "default" {
  name   = "default"
  vpc_id = var.vpc_id
}

# AWS EC2 Security Group Terraform Module
# Security Group for Public Bastion Host
module "public_bastion_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.0.0"

  name = "${local.name}-bastion-sg"
  description = "Security Group with SSH port open for everybody (IPv4 CIDR), egress ports are all world open"
  vpc_id = var.vpc_id
  # Ingress Rules & CIDR Blocks
  ingress_rules = ["ssh-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  # Egress Rule - all-all open
  egress_rules = ["all-all"]
  tags = local.common_tags
}

# AWS EC2 Security Group Terraform Module
# Security Group for Private EC2 Instances
/* module "private_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.0.0"

  name = "private-sg"
  description = "Security Group with HTTP & SSH port open for entire VPC Block (IPv4 CIDR), egress ports are all world open"
  vpc_id = var.vpc_id
  # Ingress Rules & CIDR Blocks
  ingress_rules = ["ssh-tcp", "http-80-tcp"]
  ingress_cidr_blocks = [module.vpc.vpc_cidr_block]
  ingress_with_source_security_group_id = [
    {
      rule = "https-443-tcp"
      ingress_with_source_security_group_id = data.aws_security_group.default.id
    },
  ]
  # Egress Rule - all-all open
  egress_rules = ["all-all"]
  tags = local.common_tags
} */

# Get latest AMI ID for Amazon Linux2 OS
data "aws_ami" "amzlinux2" {
  most_recent = true
  owners = [ "amazon" ]
  filter {
    name = "name"
    values = [ "amzn2-ami-hvm-*-gp2" ]
  }
  filter {
    name = "root-device-type"
    values = [ "ebs" ]
  }
  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
  filter {
    name = "architecture"
    values = [ "x86_64" ]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_ami" "battlerocket" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["bottlerocket-aws-k8s-????-x86_64-*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

#######################################################################
# SSH Key Gen
#######################################################################
resource "tls_private_key" "this" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = trimspace(tls_private_key.this.public_key_openssh)

  ## Local Exec Provisioner:  local-exec provisioner (Creation-Time Provisioner - Triggered during Create Resource)
  provisioner "local-exec" {
    command = "echo '${tls_private_key.this.private_key_openssh}' > terraform-key.pem"
    working_dir = var.working_dir
  }
}

#######################################################################
# AWS EC2 Instance Terraform Module
# Bastion Host - EC2 Instance that will be created in VPC Public Subnet
#######################################################################
/* data "aws_subnet_ids" "public_subnets" {
  vpc_id = var.vpc_id

  tags = {
    Name= "*-Public-*"
  }
} */

data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = {
    Name = "*-Public-*"
  }
}
/* data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  tags = {
    Tier = "Private"
  }
} */

module "ec2_bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "4.3.0"
  # insert the 10 required variables here
  name                   = "${var.environment}-bastion"
  # ami                    = data.aws_ami.amzlinux2.id
  ami                    = data.aws_ami.battlerocket.id
  #ami_ssm_parameter      = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
  #availability_zone      = "ap-northeast-2a"
  create                 = true
  instance_type          = var.instance_type
  key_name               = aws_key_pair.generated_key.key_name
  monitoring             = true
  associate_public_ip_address = true
  #subnet_id               = element(data.aws_subnet_ids.public_subnets.ids, 0)
  subnet_id               = data.aws_subnets.selected.ids[0]

  vpc_security_group_ids = [module.public_bastion_sg.this_security_group_id]

  # Instance_Profile
  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  
#   instance_count         = var.private_instance_count
  # user_data = ("${path.module}/app1-install.sh")
  user_data = local.userdata
  tags = local.common_tags
}

# AWS EC2 Instance Terraform Module
# EC2 Instances that will be created in VPC Private Subnets
/* module "ec2_private" {
  depends_on = [ module.vpc ] # VERY VERY IMPORTANT else userdata webserver provisioning will fail
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "3.3.0"
   #for_each = toset([ module.vpc.private_subnets[0],module.vpc.private_subnets[1] ])
  # insert the 10 required variables here
  for_each = local.multi_instances

  name                   = "${local.name}-${each.key}"
  ami                    = data.aws_ami.amzlinux2.id
  instance_type          = each.value.instance_type
  key_name               = var.instance_keypair
  #monitoring             = true
  vpc_security_group_ids = [module.private_sg.this_security_group_id]

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 8
  }

  # Instance_Profile
  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  
  subnet_id =  element(module.vpc.private_subnets, 0)
#   instance_count         = var.private_instance_count
  user_data = file("${path.module}/app1-install.sh")
  tags = local.common_tags
} */

#######################################################################
# Create Elastic IP for Bastion Host
# Resource - depends_on Meta-Argument
#######################################################################
resource "aws_eip" "bastion_eip" {
  depends_on = [module.ec2_bastion]
  instance = module.ec2_bastion.id
  vpc      = true
  tags = local.common_tags

## Local Exec Provisioner:  local-exec provisioner (Destroy-Time Provisioner - Triggered during deletion of Resource)
  /* provisioner "local-exec" {
    command = "echo Destroy time prov `date` >> destroy-time-prov.txt"
    working_dir = "local-exec-output-files/"
    when = destroy
    #on_failure = continue
  }  */ 
}

#######################################################################
# Create a Null Resource and Provisioners
#######################################################################
resource "null_resource" "name" {
  count = var.enable_sshkey== true ? 1 : 0

  depends_on = [module.ec2_bastion, aws_eip.bastion_eip, aws_key_pair.generated_key]
  # Connection Block for Provisioners to connect to EC2 Instance
  connection {
    type     = "ssh"
    host     = aws_eip.bastion_eip.public_ip    
    user     = "ec2-user"
    password = ""
    private_key = file( "${var.working_dir}/${var.key_name}" )
  }  

## File Provisioner: Copies the terraform-key.pem file to /tmp/terraform-key.pem
  provisioner "file" {
    #source      = "private-key/terraform-key.pem"
    source = "${var.working_dir}/${var.key_name}"
    destination = "/tmp/terraform-key.pem"
  }
## Remote Exec Provisioner: Using remote-exec provisioner fix the private key permissions on Bastion Host
  provisioner "remote-exec" {
    inline = [
      "sudo chmod 400 /tmp/terraform-key.pem"
    ]
  }
## Local Exec Provisioner:  local-exec provisioner (Creation-Time Provisioner - Triggered during Create Resource)
  /* provisioner "local-exec" {
    command = "echo VPC created on `date` and VPC ID: ${var.vpc_id} >> creation-time-vpc-id.txt"
    working_dir = "local-exec-output-files/"
    #on_failure = continue
  } */
}

# Creation Time Provisioners - By default they are created during resource creations (terraform apply)
# Destory Time Provisioners - Will be executed during "terraform destroy" command (when = destroy)