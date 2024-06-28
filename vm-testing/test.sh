#!/bin/bash -e

podman build test/ -f test/Containerfile -t fedora-cosign:latest

base_hostname=$(grep tas_single_node_base_hostname: play.yml | awk '{print $2}')
ip_address=$(ansible-inventory --list rhtas | jq '.rhtas | .hosts | .[]' | tr -d '"')
oidc_url=$(grep tas_single_node_oidc_issuers: vars.yml | awk '{print $2}' | tr -d '"' | awk -F'/' '{print $1FS$2FS$3}')
username=jdoe
password=secure

cat << EOF

Running test with:
base_hostname=${base_hostname}
ip_address=${ip_address}
oidc_url=${oidc_url}
username=${username}
password=${password}

EOF

if  [ -z "${base_hostname}" -o -z "${ip_address}" -o -z "${oidc_url}" -o -z "${username}" -o -z "${password}" ]; then
  echo "Couldn't extract some testing parameters, see above and fix."
  exit 1
fi

podman run \
  -v $(pwd)/test:/mnt:z \
  -ti --rm \
  --add-host fulcio.${base_hostname}:${ip_address} \
  --add-host rekor.${base_hostname}:${ip_address} \
  --add-host tuf.${base_hostname}:${ip_address} \
  -e BASE_HOSTNAME=${base_hostname} \
  -e USERNAME=${username} \
  -e PASSWORD=${password} \
  -e KEYCLOAK_URL=${oidc_url} \
  fedora-cosign:latest /bin/bash /mnt/test-sign-blob.sh
