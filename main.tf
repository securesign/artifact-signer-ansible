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

data "aws_ami" "rhel9" {
  most_recent = true
  filter {
    name = "name"
    values = ["RHEL-9*"]
  }
  filter {
    name = "architecture"
    values = ["x86_64"]
  }
}

variable "rh_username" {
  sensitive = true
  type = string
}

variable "rh_password" {
  sensitive = true
  type = string
}

// Create a new elastic ip address
resource "aws_eip" "eip_assoc" {
  vpc = true
}

// Associate elastic ip address with instance
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.sigstore.id
  allocation_id = aws_eip.eip_assoc.id
}

// generate a new security group to allow ssh and https traffic
resource "aws_security_group" "sigstore-access" {
  name        = "sigstore-access"
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

resource "aws_key_pair" "sigkey" {
  key_name   = uuid()
  public_key = "${file(var.ssh_public_key_path)}"
}

resource "aws_instance" "sigstore" {
  ami           = data.aws_ami.rhel9.id
  instance_type = "m5.large"
  vpc_security_group_ids = [aws_security_group.sigstore-access.id]
  key_name      = aws_key_pair.sigkey.key_name
  provisioner "remote-exec" {
    inline = [
      "sudo cloud-init status --wait",
      "echo 'Connection Established'",
      "sudo dnf -y update",
    ]
  }  
  provisioner "local-exec" {
    command = "sed  -i.bak 's/<REMOTE_IP_ADDRESS>/${aws_eip.eip_assoc.public_ip}/g' inventory"
  }
  provisioner "local-exec" {
    command = "sed -i.bak 's/ansible_user=<remote_user>/ansible_user=ec2-user/g' inventory"
  }
  provisioner "local-exec" {
    command = "ansible-galaxy collection install -r requirements.yml"
  }
  connection {
   type = "ssh"
   user = "ec2-user"
   host = self.public_ip
   private_key = file(var.ssh_private_key_path)
 }
}

resource "null_resource" "configure-sigstore" {
  depends_on = [aws_instance.sigstore]
  provisioner "local-exec" {
    command = "ansible-playbook -i inventory playbooks/install.yml -e registry_username='${var.rh_username}' -e registry_password='${var.rh_password}' -e base_hostname=${var.base_domain}"
  }
}

resource "aws_route53_record" "rekor" {
  name = "rekor.${var.base_domain}"
  type = "A"
  zone_id = data.aws_route53_zone.domain.zone_id
  records = [aws_eip.eip_assoc.public_ip]
  allow_overwrite = true
  ttl = "300"
}

resource "aws_route53_record" "fulcio" {
  name = "fulcio.${var.base_domain}"
  type = "A"
  zone_id = data.aws_route53_zone.domain.zone_id
  records = [aws_eip.eip_assoc.public_ip]
  allow_overwrite = true
  ttl = "300"
}

resource "aws_route53_record" "tuf" {
  name = "tuf.${var.base_domain}"
  type = "A"
  zone_id = data.aws_route53_zone.domain.zone_id
  records = [aws_eip.eip_assoc.public_ip]
  allow_overwrite = true
  ttl = "300"
}

resource "aws_route53_record" "keycloak" {
  name = "keycloak.${var.base_domain}"
  type = "A"
  zone_id = data.aws_route53_zone.domain.zone_id
  records = [aws_eip.eip_assoc.public_ip]
  allow_overwrite = true
  ttl = "300"
}

// Output public ip address
output "public_ip" {
  value = aws_eip.eip_assoc.public_ip
}
