variable "openstack_user_name" {}
variable "openstack_domain_name" {}
variable "openstack_token" {
  sensitive = true
}
variable "openstack_auth_url" {}
variable "openstack_tenant_name" {}
variable "openstack_ssh_key_pair" {}
variable "openstack_network" {}

variable "openstack_vm_image" {
  # temporary until we find a better image
  default = "fuseqe-20230525-RHEL-9.2.0-x86_64-ga-latest"
}
variable "openstack_flavor" {
  default = "ci.standard.large"
}
variable "openstack_az" {
  default = "nova"
}
variable "openstack_security_group" {
  default = "default"
}

provider "openstack" {
  user_name = "${var.openstack_user_name}"
  tenant_name = "${var.openstack_tenant_name}"
  token = "${var.openstack_token}"
  auth_url = "${var.openstack_auth_url}"
  domain_name = "${var.openstack_domain_name}"
}

resource "openstack_compute_instance_v2" "ansible-test" {
  count = "1"
  name = "${var.openstack_user_name}-rhtas-ansible-testing"
  image_name = "${var.openstack_vm_image}"
  availability_zone = "${var.openstack_az}"
  flavor_name = "${var.openstack_flavor}"
  key_pair = "${var.openstack_ssh_key_pair}"
  security_groups = ["${var.openstack_security_group}"]
  network {
    name = "${var.openstack_network}"
  }
}
