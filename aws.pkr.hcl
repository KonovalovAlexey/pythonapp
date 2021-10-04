packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}
variable "package" {
  type = string
}
variable "instance_profile" {
  type = string
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "Pyapp-{{timestamp}}"
  instance_type = "t2.micro"
  iam_instance_profile  = var.instance_profile
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-bionic-18.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
  ssh_pty = true
}

build {
  name    = "aws-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  provisioner "shell" {
#    environment_vars = [
#      "FOO=hello world",
#    ]
    inline = [
      "while [ ! -f  /var/lib/cloud/instance/boot-finished ]; do sleep 2; echo 'Waiting for cloud-init..'; done",
      "echo Installing Labels",
      "echo ${var.package}",
      "echo ${var.instance_profile}",
#      "sleep 30",
      "sudo apt update -y",
#      "sudo apt-get upgrade -y",
      "sudo apt-get install unzip awscli virtualenv -y",
#      "aws s3 ls",
      "env",
      "aws s3 cp ${var.package} ./package.zip",
      "unzip -o package.zip",
      "ls -alh",
      "sudo dpkg -i blog.deb"
#      "exit 1"
#      "sudo apt-get install -y redis-server",
#      "echo \"FOO is $FOO\" > example.txt",
    ]
//    script = "./scripts/packer.sh"
    timeout = "10m"

  }
}