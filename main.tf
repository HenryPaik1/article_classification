# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY AN INSTANCE, THEN TRIGGER A PROVISIONER
# See test/terraform_ssh_example.go for how to write automated tests for this code.
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
region = "ap-northeast-2"
}

data "aws_security_group" "default" {
name = "default"
}

data "aws_security_group" "security_dss" {
name = "security_dss"
}


resource "aws_key_pair" "dss_key" {
key_name = "dss_key"
public_key = "${file("~/.ssh/dss_key.pub")}"
}

resource "aws_security_group" "dss-terraform" {
name = "security_dss"
description = "dss group"

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


resource "aws_instance" "article_clf" {
  ami                    = "ami-06e7b9c5e0c4dd014"
  instance_type          = "t2.micro"
  vpc_security_group = ["${aws_security_group.security_dss.id}"]
  key_name               = "dss_key"

  # This EC2 Instance has a public IP and will be accessible directly from the public Internet
  associate_public_ip_address = true

  tags = {
    Name = "{var.instance_name}"
  }
  
}



resource "aws_security_group" "article_clf" {
  name = "${var.instance_name}"

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = "${var.ssh_port}"
    to_port   = "${var.ssh_port}"
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Provision the server using remote-exec
# ---------------------------------------------------------------------------------------------------------------------

resource "null_resource" "clf_null" {
  triggers {
    public_ip = "${aws_instance.article_clf.public_ip}"
  }

  connection {
    type = "ssh"
    host = "${aws_instance.article_clf.public_ip}"
    user = "${var.ssh_user}"
    port = "${var.ssh_port}"
    agent = true
  }

   provisioner "remote-exec" {
                            inline = [
                            "sudo apt-get update",
                            "sudo apt-get -y install python3-pip",
                            "sudo apt-get -y install unzip",
                            "unzip chromedriver_linux64.zip",
                            "git clone https://github.com/HenryPaik1/article_classification.git",
                            "python3 run_article.py 0"]
                            

 
}
