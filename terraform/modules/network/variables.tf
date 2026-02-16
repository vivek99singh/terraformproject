variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_cidr" {
  type = string
}

variable "subnet_cidrs" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}