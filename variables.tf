variable "aws_region" {
  type    = string
  default = "sa-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "meu_ip" {
  type        = string
  description = "Preencha com o seu IP público para acesso SSH"
}