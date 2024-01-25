variable "vpc_id" {
  type = string
}

variable "ssh_public_key_path" {
  type = string
  default = "~/.ssh/id_rsa.pub"
}

variable "ssh_private_key_path" {
  type = string
  default = "~/.ssh/id_rsa"
}

variable "base_domain" {
  type = string
}

data "aws_route53_zone" "domain" {
  name        = var.base_domain
  private_zone = false
}

data "aws_ami" "fedora_bootc" {
  most_recent = true
  filter {
    name = "name"
    values = ["fedora-bootc-ami"]
  }
  filter {
    name = "architecture"
    values = ["arm64"]
  }
}

// Create a new elastic ip address
resource "aws_eip" "eip_assoc" {
  domain = "vpc"
}

// Associate elastic ip address with instance
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.fedora_bootc_test.id
  allocation_id = aws_eip.eip_assoc.id
}

// generate a new security group to allow ssh and https traffic
resource "aws_security_group" "fedora-bootc-access" {
  name        = "fedora-bootc-access"
  description = "Allow ssh and https traffic"
  vpc_id      = var.vpc_id
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "CHATAPP"
    from_port   = 7860
    to_port     = 7860
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "sshkey" {
  key_name   = uuid()
  public_key = "${file(var.ssh_public_key_path)}"
}

resource "aws_instance" "fedora_bootc_test" {
  ami           = data.aws_ami.fedora_bootc.id
  instance_type = "a1.xlarge"
  vpc_security_group_ids = [aws_security_group.fedora-bootc-access.id]
  key_name      = aws_key_pair.sshkey.key_name
  provisioner "remote-exec" {
    inline = [
      "echo 'Connection Established'",
    ]
  }  

//  provisioner "local-exec" {
//    command = "sed  -i.bak 's/<REMOTE_IP_ADDRESS>/${aws_eip.eip_assoc.public_ip}/g' inventory"
//  }
//  provisioner "local-exec" {
//    command = "ansible-galaxy collection install -r requirements.yml"
//  }

  connection {
   type = "ssh"
   user = "fedora"
   private_key = file(var.ssh_private_key_path)
   host = self.public_ip
 }
}

//resource "null_resource" "configure-instance" {
//  depends_on = [aws_instance.fedora_bootc_test]
//  provisioner "local-exec" {
//  command = "ansible-playbook -i inventory playbooks/install.yml -e registry_username='${var.rh_username}' -e registry_password='${var.rh_password}' -e base_hostname=${var.base_domain}"
//  }
//}

// Output public ip address
output "public_ip" {
  value = aws_eip.eip_assoc.public_ip
}
