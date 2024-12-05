variable "public_subnets_id" {
  type = list(string)
}

variable "sg_loadbalance_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "domain_cert_arn" {
  type = string
}