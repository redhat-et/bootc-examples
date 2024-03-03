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

data "aws_ami" "rhel_bootc" {
  most_recent = true
  filter {
    name = "name"
    values = ["somal-rhel-bootc-94"]
  }
  filter {
    name = "architecture"
    values = ["x86_64"]
  }
}

// Create a new elastic ip address
resource "aws_eip" "eip_assoc" {
  domain = "vpc"
}

// Associate elastic ip address with instance
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.rhel_bootc_test.id
  allocation_id = aws_eip.eip_assoc.id
}

// generate a new security group to allow ssh and https traffic
resource "aws_security_group" "rhel-bootc-access" {
  name        = "rhel-bootc-access"
  description = "Allow ssh and https traffic"
  vpc_id      = var.vpc_id
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "CHATAPP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "MODELSERVICE"
    from_port   = 8501
    to_port     = 8501
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS"
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

resource "aws_instance" "rhel_bootc_test" {
  ami           = data.aws_ami.rhel_bootc.id
  root_block_device {
    volume_size = 90
    volume_type = "gp3"
  }
  //cpu_options {
  //  core_count       = 32
  //  threads_per_core = 1
  //}
  //instance_type = "c6gd.8xlarge"
  instance_type = "g5.2xlarge"
  vpc_security_group_ids = [aws_security_group.rhel-bootc-access.id]
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
   user = "root"
   private_key = file(var.ssh_private_key_path)
   host = self.public_ip
 }
}

//resource "null_resource" "configure-instance" {
//  depends_on = [aws_instance.rhel_bootc_test]
//  provisioner "local-exec" {
//  command = "ansible-playbook -i inventory playbooks/install.yml -e registry_username='${var.rh_username}' -e registry_password='${var.rh_password}' -e base_hostname=${var.base_domain}"
//  }
//}

// Output public ip address
output "public_ip" {
  value = aws_eip.eip_assoc.public_ip
}
