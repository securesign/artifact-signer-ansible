#!/usr/bin/env bash
set -ex

# NOTE: this script requires BASE_HOSTNAME and KEYCLOAK_URL to be set

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
export COSIGN_OIDC_CLIENT_ID=example-app
export COSIGN_OIDC_ISSUER=$OIDC_ISSUER_URL
export COSIGN_CERTIFICATE_OIDC_ISSUER=$OIDC_ISSUER_URL
export COSIGN_YES="true"
export SIGSTORE_FULCIO_URL=$COSIGN_FULCIO_URL
export SIGSTORE_OIDC_ISSUER=$COSIGN_OIDC_ISSUER
export SIGSTORE_REKOR_URL=$COSIGN_REKOR_URL
export REKOR_REKOR_SERVER=$COSIGN_REKOR_URL
export EMAIL=kilgore@kilgore.trout

AUTHTOKEN="$(curl -Lis "http://dex-idp:5556/dex/auth/mock?client_id=example-app&scope=openid%20email&redirect_uri=http://dex-idp:5556/callback&response_type=code" | grep -oP "code=\K[^&]+")"
export AUTHTOKEN

if [ -z "${AUTHTOKEN}" ]; then
  echo "Error: Unable to fetch authorization code."
  exit 1
fi

TOKEN="$(curl -s -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "grant_type=authorization_code" -d "code=${AUTHTOKEN}" -d "redirect_uri=http://dex-idp:5556/callback" -d "client_id=example-app" -d "client_secret=ZXhhbXBsZS1hcHAtc2VjcmV0" "http://dex-idp:5556/dex/token" | sed -n 's/.*"access_token":"\([^"]*\)".*/\1/p')"
export TOKEN

if [ -z "${TOKEN}" ]; then
  echo "Error: Unable to fetch access code."
  exit 1
fi

env
cosign initialize

echo "testing" > to-sign

cosign --verbose sign-blob to-sign --bundle signed.bundle --identity-token="${TOKEN}" --timestamp-server-url="${COSIGN_TSA_URL}" --rfc3161-timestamp=timestamp.txt

cosign --verbose verify-blob --certificate-identity="${EMAIL}" --bundle signed.bundle to-sign --rfc3161-timestamp=timestamp.txt --use-signed-timestamps
