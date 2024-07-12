#!/usr/bin/env bash

if [ -z "$1" ]; then
  echo "Please provide a cloud provider to use - currently only openstack is available"
  exit 1
fi

cd "$1"
tofu destroy -var-file=terraform.tfvars

cat << EOF
Don't forget to remove all lines matching ".myrhtas" from /etc/hosts:

sudo sed -i "/\.myrhtas/d" /etc/hosts
EOF
