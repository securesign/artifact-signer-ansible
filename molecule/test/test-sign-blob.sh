#!/usr/bin/env bash
set -ex

# NOTE: this script requires BASE_HOSTNAME

# extract the root certificate and make it trusted
script_dir="$(dirname "$(readlink -f "$0")")"
source "${script_dir}/extract_root_cert.sh"
extractRootCert "rekor.${BASE_HOSTNAME}" "/etc/pki/ca-trust/source/anchors/${BASE_HOSTNAME}.pem"
update-ca-trust

# set up cosign env
export TUF_URL=https://tuf.$BASE_HOSTNAME
export OIDC_ISSUER_URL=$OIDC_ISSUER_URL
export COSIGN_FULCIO_URL=https://fulcio.$BASE_HOSTNAME
export COSIGN_REKOR_URL=https://rekor.$BASE_HOSTNAME
export COSIGN_TSA_URL=https://tsa.$BASE_HOSTNAME/api/v1/timestamp
export COSIGN_MIRROR=$TUF_URL
export COSIGN_ROOT=$TUF_URL/root.json
export COSIGN_OIDC_CLIENT_ID=trusted-artifact-signer
export COSIGN_OIDC_ISSUER=$OIDC_ISSUER_URL
export COSIGN_CERTIFICATE_OIDC_ISSUER=$OIDC_ISSUER_URL
export COSIGN_YES="true"
export SIGSTORE_FULCIO_URL=$COSIGN_FULCIO_URL
export SIGSTORE_OIDC_ISSUER=$COSIGN_OIDC_ISSUER
export SIGSTORE_REKOR_URL=$COSIGN_REKOR_URL
export REKOR_REKOR_SERVER=$COSIGN_REKOR_URL
export EMAIL=jdoe@redhat.com

TOKEN="$(curl -s -X POST 'http://dex-idp:5556/dex/token' \
-H 'Authorization: Basic dHJ1c3RlZC1hcnRpZmFjdC1zaWduZXI6WlhoaGJYQnNaUzFoY0hBdGMyVmpjbVYw' \
-H 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=password' \
--data-urlencode 'scope=openid email profile' \
--data-urlencode 'username=jdoe@redhat.com' \
--data-urlencode 'password=secure' | sed -n 's/.*"access_token":"\([^"]*\)".*/\1/p')"
export TOKEN

if [ -z "${TOKEN}" ]; then
  echo "Error: Unable to fetch access code."
  exit 1
fi

env
cd /test
FILENAME="$(date +%Y%m%d%H%M%S)"
cosign initialize --mirror="${COSIGN_MIRROR}" --root="${COSIGN_ROOT}"

echo "testing" > "$FILENAME.txt"

cosign --verbose sign-blob "$FILENAME.txt" --bundle "$FILENAME.bundle" --identity-token="${TOKEN}" --use-signing-config=false

validation_counter=0
for file in /test/*.txt; do
  if [ -f "$file" ]; then  # Check if it is a regular file
    echo "Executing cosign verification on file: $file"
    cosign --verbose verify-blob \
        --certificate-identity="${EMAIL}" \
        --certificate-oidc-issuer="${COSIGN_OIDC_ISSUER}" \
        --bundle "${file%.*}.bundle" \
        --trusted-root "/root/.sigstore/root/targets/trusted_root.json" \
        "$file"

   validation_counter=$((validation_counter + 1))
  fi
done

if [ "$validation_counter" -eq 0 ]; then
  echo "Error: No files processed. Exiting with non-zero status."
  exit 1
fi

echo "Total file validations: $validation_counter"
