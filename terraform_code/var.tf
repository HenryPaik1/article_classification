
variable "aws_region" {
  description = "The AWS region to deploy into"
  default     = "ap-northeast-1"
}

variable "instance_name" {
  description = "The Name tag to set for the EC2 Instance."
  default     = "clf"
}

variable "ssh_port" {
  description = "The port the EC2 Instance should listen on for SSH requests."
  default     = 22
}

variable "ssh_user" {
  description = "SSH user name to use for remote exec connections,"
  default     = "ubuntu"
}