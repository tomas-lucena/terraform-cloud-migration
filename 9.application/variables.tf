variable "ami_id" {
  type = string
}


variable "private_subnets_id" {
  type = list(string)
}

variable "lb_target_group_arn" {
  type = string
}

variable "sg_application_id" {
  type = string
}

variable "vpc_id" {
  type = string
}