
locals {
  vpc_id        = data.aws_subnet.my_subnet.vpc_id
  my_az         = data.aws_subnet.selected.availability_zone
  instance_type = contains(data.aws_ec2_instance_type_offerings.m5_types.instance_types, var.preferred_instance_type) ? var.preferred_instance_type : element(data.aws_ec2_instance_type_offerings.m5_types.instance_types, 0)
}

data "aws_ami" "linux_image" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

}

#Fetching a subnet to identify its VPC ID
data "aws_subnet" "my_subnet" {
  filter {
    name   = "tag:Name"
    values = ["*-01"]
  }
}

#local block with VPC Ids updated at the beginning of the code

#Fetching all subnets within VPC
data "aws_subnets" "all_subnets" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
}

#Filtering subnets based on its availability
data "aws_subnet" "selected" {
  id = element(data.aws_subnets.all_subnets.ids, 0)
}

#Choosing subnet based on AZ
data "aws_subnet" "selected_subnet" {
  filter {
    name   = "availabilityZone"
    values = [local.my_az]
  }
}

# Data source to fetch available instance types for m5 family
data "aws_ec2_instance_type_offerings" "m5_types" {
  location_type = "region"

  filter {
    name = "instance-type"
    #values = ["t3.small", "t3.medium", "t3.large", "t3.xlarge", "t3.2xlarge"]
    values = ["m5.2xlarge", "m5.4xlarge", "m5.8xlarge", "m5.12xlarge", "m5.16xlarge"]
  }
}

#Generate random string for instance names
resource "random_string" "random_name" {
  length  = var.instance_name_length
  numeric = true
  special = false
  lower   = true
  upper   = false
}

#Create Security Group
resource "aws_security_group" "my_sg" {
  name        = "dev_security_group"
  description = "Allow SSH and TLS inbound traffic and all outbound traffic"
  vpc_id      = local.vpc_id

  tags = {
    Name = "ssh_tls_ssl"
  }
}

#Allow TLS ingress
resource "aws_vpc_security_group_ingress_rule" "allow_tls" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.my_sg.id
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = data.aws_subnet.selected_subnet.cidr_block
}

#Allow ssh ingress
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.my_sg.id
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "0.0.0.0/0"
}

#Allow all outbound connection
resource "aws_vpc_security_group_egress_rule" "allow_all" {
  ip_protocol       = "-1" # equivalent to all ports
  security_group_id = aws_security_group.my_sg.id
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_instance" "test_instance" {
  ami             = data.aws_ami.linux_image.id
  instance_type   = local.instance_type
  subnet_id       = data.aws_subnet.selected_subnet.id
  security_groups = [aws_security_group.my_sg.id]
  key_name        = var.keys

  #Only supported for certain types of instances such as m5, m6 or ultra
  #This only modifies the core per CPU, not the actual vCPU which is useful while handling licensing
  cpu_options {
    core_count       = var.core_count
    threads_per_core = 2
  }

  tags = {
    Name = random_string.random_name.id
  }

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.volume_type
    delete_on_termination = true
  }

  ebs_block_device {
    device_name           = "/dev/sdh"
    volume_size           = var.ebs_size
    volume_type           = var.volume_type
    delete_on_termination = true
  }

}


