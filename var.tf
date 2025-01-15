variable "region" {
  type        = string
  description = "Cloud Region to use"
}

variable "subnet_id" {
  type        = string
  description = "subnet ID"
}

variable "instance_name_length" {
  type        = number
  description = "Length of Instance name in numbers"
  default     = 12
}

variable "root_volume_size" {
  type        = number
  description = "Boot volume size in GB"
  default     = 20
}

variable "ebs_size" {
  type        = number
  description = "Block volume size in GB"
  default     = 30
}

variable "volume_type" {
  type        = string
  description = "Choose among gp2, gp3 (general purpose) or io1/io2 for high performance ssd volume"
  default     = "gp3"
}

/*
variable "az" {
  type = map(string)
  description = "List of AZs"
  default = {
    "Mumbai_AZ1" = "ap-south-1a"
    "Mumbai_AZ2" = "ap-south-1b"
  }
}

variable "instance_type" {
  type        = string
  description = "Instance type to use"
}

*/

variable "keys" {
  type        = string
  description = "ssh Keys to be used"
  default     = "Instance_key01"
}

variable "preferred_instance_type" {
  description = "Preferred instance type"
  type        = string
  default     = "m5.2kxlarge"
}

variable "core_count" {
  description = "Custom number of vCPUs"
  type        = number
  default     = 4
}







