variable "vpc_id" {
  type = string
}

variable "base_domain" {
  type = string
}

data "aws_route53_zone" "domain" {
  name        = var.base_domain
  private_zone = false
}

data "aws_ami" "rhel8" {
  most_recent = true
  filter {
    name = "name"
    values = ["RHEL-8*"]
  }
  filter {
    name = "architecture"
    values = ["x86_64"]
  }
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

// Generate Private and Public Key and upload to aws
 resource "tls_private_key" "terrafrom_generated_private_key" {
   algorithm = "RSA"
   rsa_bits  = 4096
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

 resource "aws_key_pair" "generated_key" {
 
   # Name of key: Write the custom name of your key
   key_name   = "aws_keys_pairs"
 
   # Public Key: The public will be generated using the reference of tls_private_key.terrafrom_generated_private_key
   public_key = tls_private_key.terrafrom_generated_private_key.public_key_openssh
 
   # Store private key :  Generate and save private key(aws_keys_pairs.pem) in current directory
   provisioner "local-exec" {
     command = <<-EOT
       echo '${tls_private_key.terrafrom_generated_private_key.private_key_pem}' > aws_keys_pairs.pem
       chmod 400 aws_keys_pairs.pem
     EOT
   }
 }

resource "aws_instance" "sigstore" {
  ami           = data.aws_ami.rhel8.id
  instance_type = "m5.large"
  vpc_security_group_ids = [aws_security_group.sigstore-access.id]
  key_name      = aws_key_pair.generated_key.key_name
  provisioner "remote-exec" {
    inline = [
      "sudo cloud-init status --wait",
      "echo 'Connection Established'",
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
   private_key = tls_private_key.terrafrom_generated_private_key.private_key_pem
   host = self.public_ip
 }
}

resource "null_resource" "configure-sigstore" {
  depends_on = [aws_instance.sigstore]
  provisioner "local-exec" {
    command = "ansible-playbook -i inventory playbooks/install.yml -e base_hostname=${var.base_domain}"
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
  value = aws_instance.sigstore.public_ip
}
