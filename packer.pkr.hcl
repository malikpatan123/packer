packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# Declare input variables
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "region" {}
variable "source_ami" {}
variable "instance_type" {}
variable "vpc_id" {}
variable "subnet_id" {}

# Define the Amazon EC2 builder
source "amazon-ebs" "ubuntu" {
  access_key      = var.aws_access_key
  secret_key      = var.aws_secret_key
  region          = var.region
  source_ami      = var.source_ami
  instance_type   = var.instance_type
  ssh_username    = "ubuntu"
  ami_name = "malik-patan-Build-${formatdate("YYYY-MM-DD-HH-mm-ss", timestamp())}"  
  vpc_id          = var.vpc_id
  subnet_id       = var.subnet_id

  tags = {
    Name = "malik-patan-Build-${formatdate("YYYY-MM-DD-HH-mm-ss", timestamp())}"
  }
}

# Define the build block and provisioners
build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    inline = [
      "sleep 30",
      "sudo apt update -y",
      "sudo apt install nginx -y",
      "sudo apt install git -y",
      "sudo git clone https://github.com/malikpatan123/webhooktesting.git",
      "sudo rm -rf /var/www/html/index.nginx-debian.html",
      "sudo cp webhooktesting/index.html /var/www/html/index.nginx-debian.html",
      "sudo cp webhooktesting/style.css /var/www/html/style.css",
      "sudo cp webhooktesting/scorekeeper.js /var/www/html/scorekeeper.js",
      "sudo service nginx start",
      "sudo systemctl enable nginx",
      "curl https://get.docker.com | bash"
    ]
  }

  provisioner "file" {
    source      = "docker.service"
    destination = "/tmp/docker.service"
  }

  provisioner "shell" {
    inline = [
      "sudo cp /tmp/docker.service /lib/systemd/system/docker.service",
      "sudo usermod -a -G docker ubuntu",
      "sudo systemctl daemon-reload",
      "sudo service docker restart"
    ]
  }
}

 
