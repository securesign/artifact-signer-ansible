#!/usr/bin/env bash

if [ -z "$1" ]; then
  echo "Please provide a cloud provider to use - currently only openstack is available"
  exit 1
fi

cd "$1"
tofu init
tofu apply -var-file=terraform.tfvars

if [ "$1" == "openstack" ]; then
  ip_address="$(tofu state show openstack_compute_instance_v2.ansible-test[0] | grep access_ip_v4 | awk '{print $3}' | tr -d '"')"
  vm_username=cloud-user
else
  echo "Only openstack provider is currently supported"
  exit 1
fi

(sed -e "s/REMOTE_IP_ADDRESS/$ip_address/" -e "s/ANSIBLE_USER/$vm_username/" inventory-sample > inventory)

cat << EOF
Please add the following lines to your /etc/hosts:

sudo bash -c "cat << EOT >> /etc/hosts
$ip_address fulcio.myrhtas
$ip_address tuf.myrhtas
$ip_address rekor.myrhtas
EOT"
EOF
