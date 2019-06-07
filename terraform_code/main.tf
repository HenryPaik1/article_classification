# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY AN INSTANCE, THEN TRIGGER A PROVISIONER
# ---------------------------------------------------------------------------------------------------------------------


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
  triggers= {
    public_ip = "${aws_instance.article_clf.public_ip}"
  }

  connection {
    type = "ssh"
    host = "${aws_instance.article_clf.public_ip}"
        private_key = "${file("~/.ssh/dss_key")}"

    user = "${var.ssh_user}"
    port = "${var.ssh_port}"
    timeout = "1m"
  }

   provisioner "remote-exec" {
                            inline = [
                            "sudo apt-get update",
                            "sudo apt-get -y install python3-pip",

                            "sudo apt-get update",
                            "pip3 install selenium",

                            "sudo apt-get -y install unzip",

                            "wget https://chromedriver.storage.googleapis.com/75.0.3770.8/chromedriver_linux64.zip",
                            "unzip chromedriver_linux64.zip",


                            "wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -",
                            "sudo sh -c \"echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' >> /etc/apt/sources.list.d/google.list\"",
                            "sudo apt-get -y update",
                            "sudo apt-get -y install google-chrome-stable",
                            "sudo apt --fix-broken -y install",

                            "git clone https://github.com/HenryPaik1/article_classification.git",
                            "python3 ~/article_classification/run_article.py 0"
                            ]
                           }
    }

