variable "base_cidr_block" {
  type = string
}

variable "number_private_subnets" {
  type = number
}

variable "number_public_subnets" {
  type = number
}

variable "region" {
  type = string
}

variable "sg_application_id" {
  type = string
}

variable "vpc_id" {
  type = string
}