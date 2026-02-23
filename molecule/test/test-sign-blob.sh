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
export COSIGN_YES="true"
export EMAIL=jdoe@redhat.com

TOKEN="$(curl -s -X POST "$OIDC_ISSUER_URL/token" -k \
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
cosign initialize

echo "testing" > "$FILENAME.txt"

# With a TUF repo that includes signing_config.v0.2.json and trusted_root.json
# cosign v3 defaults handle everything:
#
#   export COSIGN_MIRROR=https://tuf.$BASE_HOSTNAME
#   export COSIGN_ROOT=$COSIGN_MIRROR/root.json
#   export COSIGN_OIDC_CLIENT_ID=trusted-artifact-signer
#   export COSIGN_YES="true"
#   cosign initialize
#
#   cosign sign-blob "$FILE" --bundle "$FILE.bundle" --identity-token="$TOKEN"
#
#   cosign verify-blob \
#       --certificate-identity="$EMAIL" \
#       --certificate-oidc-issuer="$OIDC_ISSUER_URL" \
#       --bundle "$FILE.bundle" \
#       "$FILE"

# Legacy fallback: explicit service URLs for TUF repos without signing config
cosign --verbose sign-blob "$FILENAME.txt" --bundle "$FILENAME.bundle" --identity-token="${TOKEN}" --use-signing-config=false --new-bundle-format=false --timestamp-server-url="${COSIGN_TSA_URL}" --rfc3161-timestamp="$FILENAME.timestamp"

validation_counter=0
for file in /test/*.txt; do
  if [ -f "$file" ]; then  # Check if it is a regular file
    echo "Executing cosign verification on file: $file"
    cosign --verbose verify-blob \
        --certificate-identity="${EMAIL}" \
        --certificate-oidc-issuer="${COSIGN_OIDC_ISSUER}" \
        --bundle "${file%.*}.bundle" \
        --rfc3161-timestamp="${file%.*}.timestamp" \
        --use-signed-timestamps \
        --new-bundle-format=false \
        "$file"

   validation_counter=$((validation_counter + 1))
  fi
done

if [ "$validation_counter" -eq 0 ]; then
  echo "Error: No files processed. Exiting with non-zero status."
  exit 1
fi

echo "Total file validations: $validation_counter"
