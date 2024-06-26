# artifact-signer-ansible

Automation to deploy the RHTAS ecosystem on RHEL

:warning: **The contents of this repository are a Work in Progress.**

## Overview

The automation within this repository establishes the components of RHTAS, the downstream redistribution of  [Sigstore project](https://sigstore.dev) within a single
Red Hat Enterprise Linux (RHEL) machine using a standalone containerized deployment.
Containers are spawned using Kubernetes based manifests using
[podman kube play](https://docs.podman.io/en/latest/markdown/podman-kube-play.1.html).

The following Sigstore components are deployed as part of this architecture:

* [Rekor](https://docs.sigstore.dev/rekor/overview)
    * [Trillian](https://github.com/google/trillian)
* [Fulcio](https://docs.sigstore.dev/fulcio/overview)
* [Certificate Log](https://docs.sigstore.dev/fulcio/certificate-issuing-overview)

An [NGINX](https://www.nginx.com) frontend is placed as an entrypoint to the various backend components. Communication is secured via a set of self-signed certificates that are generated at runtime.

Utilize the steps below to understand how to setup and execute the provisioning.

## Prerequisites
A RHEL 8.8+ or a RHEL 9.2+ server should be used to run the RHTAS components.

Ansible must be installed and configured on a control node that will be used to perform the automation.

NOTE: Future improvements will make use of an Execution environment

Perform the following steps to prepare the control node for execution.

### Dependencies

Install the required Ansible collections by executing the following

```shell
ansible-galaxy collection install -r requirements.yml
```

### Inventory

Populate the `sigstore` group within the [inventory](inventory) file with details related to the target host.

### OIDC provider
An installation of Keycloak must be provided to allow for integration with containerized RHTAS.

### Ingress

The automation deploys and configures a software load balancer as a central point of ingress. Multiple hostnames underneath a _base hostname_ are configured and include the following hostnames:

* https://rekor.<base_hostname>
* https://fulcio.<base_hostname>
* https://tuf.<base_hostname>

each of these hostnames must be configured in DNS to resolve to the target machine. The `base_hostname` parameter must be provided
when executing the provisining. To configure hostnames in DNS, edit `/etc/hosts` with the following content:

```
<REMOTE_IP_ADDRESS> fulcio.<base_hostname> fulcio
<REMOTE_IP_ADDRESS> rekor.<base_hostname> rekor
<REMOTE_IP_ADDRESS> tuf.<base_hostname> tuf
```

### Cosign

[cosign](https://github.com/sigstore/cosign) is used as part of testing and validating the setup and configuration. It is an optional install if there is not a desire to perform the validation as described below.

## Provision

Execute the following commands to execute the automation:

NOTE: Please provide credentials to authenticate to registry.redhat.io. https://access.redhat.com/RegistryAuthentication

```shell
# Run the playbook from your local system
ansible-playbook -i inventory playbooks/install.yml -e registry_username='REGISTRY.REDHAT.IO_USERNAME' -e registry_password='REGISTRY.REDHAT.IO_PASSWORD' base_hostname=example.com'
```

### Add the root CA that was created to your local truststore.

The certificate can be downloaded from the browser Certificate Viewer by navigating to `https://rekor.<base_domain>`.
Download the _root_ certiicate that issued the rekor certificate.
In Red Hat based systems, the following commands will add a CA to the system truststore.

```shell
$ sudo openssl x509 -in ~/Downloads/root-cert-from-browser -out tas-ca.pem --outform PEM
$ sudo mv tas-ca.pem /etc/pki/ca-trust/source/anchors/
$ sudo update-ca-trust
```

## Signing a Container

Utilize the following steps to sign a container that has been published to an OCI registry

1. Export the following environment variables substituting `base_hostname` with the value used as part of the provisioning

```shell
export KEYCLOAK_REALM=trusted-artifact-signer
export BASE_HOSTNAME=<base_hostname>
export FULCIO_URL=https://fulcio.$BASE_HOSTNAME
export KEYCLOAK_URL=https://keycloak.$BASE_HOSTNAME
export REKOR_URL=https://rekor.$BASE_HOSTNAME
export TUF_URL=https://tuf.$BASE_HOSTNAME
export KEYCLOAK_OIDC_ISSUER=$KEYCLOAK_URL/realms/$KEYCLOAK_REALM
```

2. Initialize the TUF roots

```shell
cosign initialize --mirror=$TUF_URL --root=$TUF_URL/root.json
```

Note: If you have used `cosign` previously, you may need to delete the `~/.sigstore` directory

3. Sign the desired container

```shell
cosign sign -y --fulcio-url=$FULCIO_URL --rekor-url=$REKOR_URL --oidc-issuer=$KEYCLOAK_OIDC_ISSUER  <image>
```

Authenticate with the Keycloak instance using the desired credentials.

4. Verify the signed image

Refer to this example that verifies an image signed with email identity `sigstore-user@email.com` and issuer `https://github.com/login/oauth`.

```shell
cosign verify \
--rekor-url=$REKOR_URL \
--certificate-identity-regexp sigstore-user \
--certificate-oidc-issuer-regexp keycloak  \
<image>
```

If the signature verification did not result in an error, the deployment of Sigstore was successful!


## Testing
This repository contains GitHub actions that will test PRs that come in by creating an instance of RHEL 9 and deploying RHTAS then testing to ensure the image can be signed and verified.

## Feedback

Any and all feedback is welcomed. Submit an [Issue](https://github.com/securesign/artifact-signer-ansible/issues) or [Pull Request](https://github.com/securesign/artifact-signer-ansible/pulls) as desired.
