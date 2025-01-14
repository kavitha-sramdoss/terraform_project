
locals {
  vpc_id        = data.aws_subnet.my_subnet.vpc_id
  my_az         = data.aws_subnet.selected.availability_zone
  instance_type = contains(data.aws_ec2_instance_type_offerings.t3a_types.instance_types, var.preferred_instance_type) ? var.preferred_instance_type : element(data.aws_ec2_instance_type_offerings.t3a_types.instance_types, 0)
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

# Data source to fetch available instance types for T3a family
data "aws_ec2_instance_type_offerings" "t3a_types" {
  location_type = "region"

  filter {
    name   = "instance-type"
    values = ["t3a.small", "t3a.medium", "t3a.large", "t3a.xlarge", "t3a.2xlarge"]
  }
}

#Generate random string for instance names
resource "random_string" "random_name" {
  length  = 12
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
  tags = {
    Name = random_string.random_name.id
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
    delete_on_termination = true
  }

  ebs_block_device {
    device_name = "/dev/sdh"
    volume_size = 20
    volume_type = "gp2"
    delete_on_termination = true
  }

}


