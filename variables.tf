# Default Tags

variable "owner" {
  type = string
}

variable "environment" {
  type = string  
}

# Networking

variable "base_cidr_block" {
  type = string
}

variable "number_private_subnets" {
  type = number
}

variable "number_public_subnets" {
  type = number
}


# Application

variable "ami_id"{
  type = string
}

variable "region" {
  type = string
}

variable "domain" {
  type = string
}