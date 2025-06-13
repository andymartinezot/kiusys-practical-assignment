variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "certificate_arn" {
  type = string
}

variable "domain_name" {
  type = string
}
