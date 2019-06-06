# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY AN INSTANCE, THEN TRIGGER A PROVISIONER
# See test/terraform_ssh_example.go for how to write automated tests for this code.
# ---------------------------------------------------------------------------------------------------------------------
 
provider "aws" {
region = "ap-northeast-2"
  access_key = "my-access-key"
  secret_key = "my-secret-key"
}

data "aws_security_group" "default" {
name = "default"
}

resource "aws_instance" "article_clf" {
  ami                    = "ami-06e7b9c5e0c4dd014"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.security_dss.id}",
                         "${data.aws_security_group.default.id}"]
  key_name               = "dss_key"

  tags = {
    Name = "${var.instance_name}"
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
    public_key = "${file("~/.ssh/dss_key.pub")}"
    user = "${var.ssh_user}"
    port = "${var.ssh_port}"
    timeout = "1m"
  }

   provisioner "remote-exec" {
                            inline = [
                            "sudo apt-get update",
                            "sudo apt-get -y install python3-pip",
                            "sudo apt-get -y install unzip",
                            "wget https://chromedriver.storage.googleapis.com/74.0.3729.6/chromedriver_linux64.zip"
                            "unzip chromedriver_linux64.zip",
                            "git clone https://github.com/HenryPaik1/article_classification.git",
                            "python3 ~/article_classification/run_article.py 0
                            ]
                           }
    }
}
