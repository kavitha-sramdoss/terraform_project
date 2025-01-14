variable "region" {
  type        = string
  description = "Cloud Region to use"
}

variable "subnet_id" {
  type        = string
  description = "subnet ID"
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
  type = string
  description = "ssh Keys to be used"
  default = "Instance_key01"
}

variable "preferred_instance_type" {
  description = "Preferred instance type"
  type        = string
  default     = "t3a.small"
}

variable "vcpus" {
  description = "Custom number of vCPUs"
  type        = number
  default     = 4
}

variable "memory" {
  description = "Custom amount of memory (GB)"
  type        = number
  default     = 32
}






