#!/usr/bin/env bash

_help() {
  printf "Missing argument \n Usage: extractRootCert <SERVICE_HOSTNAME> <destination>"
}

extractRootCert() {
       if [ -z "$1" ]; then
         _help
         return 1
       fi

       if [ -z "$2" ]; then
         _help
         return 1
       fi

      local hostname=$1
      local baseDomain
      local dest=$2

      baseDomain=$(echo "${hostname}" | cut -d '.' -f 2)
      echo "Resolving cert for ${baseDomain}"
      temp_dir=$(mktemp -d)
      openssl s_client -showcerts -connect "${hostname}:443" < /dev/null | awk -v temp_dir="${temp_dir}" '/BEGIN CERTIFICATE/,/END CERTIFICATE/{ if(/BEGIN CERTIFICATE/){a++}; out=temp_dir "/cert"a".pem"; print >out}'
      for cert in "${temp_dir}"/*.pem; do
        newname="$(openssl x509 -noout -subject -in "$cert" | sed -nE 's/.*CN ?= ?(.*)/\1/; s/[ ,.*]/_/g; s/__/_/g; s/_-_/-/; s/^_//g;p' | tr '[:upper:]' '[:lower:]')".pem
        echo "${newname}"; mv "${cert}" "${temp_dir}/${newname}"
      done
      cp "${temp_dir}/${baseDomain}".pem "${dest}"
}