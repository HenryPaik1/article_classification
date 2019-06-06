provider "aws"{
    region = "ap-northeast-2"
}

resource "aws_key_pair" "dss_key" {
key_name = "dss_key"
public_key = "${file("~/.ssh/dss_key.pub")}"
}

resource "aws_security_group" "security_dss" {
name = "security_dss"
description = "security group"

ingress {
from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

ingress {
from_port = 80
to_port = 80
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

ingress {
from_port = 8888
to_port = 8888
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
}