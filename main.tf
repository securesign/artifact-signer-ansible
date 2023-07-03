data "aws_route53_zone" "octo" {
  name        = "octo-emerging.redhataicoe.com"
  private_zone = false
}

data "aws_eip" "by_allocation_id" {
  id = "eipalloc-0be7c4b4950490aec"
}

// Generate Private and Public Key and upload to aws
 resource "tls_private_key" "terrafrom_generated_private_key" {
   algorithm = "RSA"
   rsa_bits  = 4096
 }

// associate the eip with the instance
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.sigstore.id
  allocation_id = data.aws_eip.by_allocation_id.id
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

// Launch aws instance using ami-007cf291af489ad4d then connect to it using ssh and install podman
resource "aws_instance" "sigstore" {
  ami           = "ami-0ab8a79740bc2cec5"
  instance_type = "m5.large"
  vpc_security_group_ids = ["sg-052f8b62b8394f363"]
  key_name      = aws_key_pair.generated_key.key_name
  provisioner "remote-exec" {
    inline = [
      "sudo cloud-init status --wait",
      "echo 'Connection Established'",
    ]
  }  
  provisioner "local-exec" {
    command = "sed  -i'' -e 's/<REMOTE_IP_ADDRESS>/${data.aws_eip.by_allocation_id.public_ip}/g' inventory"
  }
  provisioner "local-exec" {
    command = "sed -i'' -e 's/ansible_user=<remote_user>/ansible_user=ec2-user/g' inventory"
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
    command = "ansible-playbook -i inventory playbooks/install.yml -e base_hostname=octo-emerging.redhataicoe.com"
  }
}

resource "aws_route53_record" "rekor" {
  name = "rekor.octo-emerging.redhataicoe.com"
  type = "A"
  zone_id = data.aws_route53_zone.octo.zone_id
  records = [data.aws_eip.by_allocation_id.public_ip]
  allow_overwrite = true
  ttl = "300"
}

resource "aws_route53_record" "fulcio" {
  name = "fulcio.octo-emerging.redhataicoe.com"
  type = "A"
  zone_id = data.aws_route53_zone.octo.zone_id
  records = [data.aws_eip.by_allocation_id.public_ip]
  allow_overwrite = true
  ttl = "300"
}

resource "aws_route53_record" "tuf" {
  name = "tuf.octo-emerging.redhataicoe.com"
  type = "A"
  zone_id = data.aws_route53_zone.octo.zone_id
  records = [data.aws_eip.by_allocation_id.public_ip]
  allow_overwrite = true
  ttl = "300"
}

resource "aws_route53_record" "keycloak" {
  name = "keycloak.octo-emerging.redhataicoe.com"
  type = "A"
  zone_id = data.aws_route53_zone.octo.zone_id
  records = [data.aws_eip.by_allocation_id.public_ip]
  allow_overwrite = true
  ttl = "300"
}

// Output public ip address
output "public_ip" {
  value = aws_instance.sigstore.public_ip
}
