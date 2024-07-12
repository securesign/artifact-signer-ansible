# artifact-signer-ansible

Automation to deploy the RHTAS ecosystem on RHEL

:warning: **The contents of this repository are a Work in Progress.**

## Overview

The automation within this repository establishes the components of RHTAS, the downstream redistribution of [Sigstore project](https://sigstore.dev) within a single Red Hat Enterprise Linux (RHEL) machine using a standalone containerized deployment. Containers are spawned using Kubernetes based manifests using
[podman kube play](https://docs.podman.io/en/latest/markdown/podman-kube-play.1.html).

The following Sigstore components are deployed as part of this architecture:

* [Rekor](https://docs.sigstore.dev/rekor/overview)
    * [Trillian](https://github.com/google/trillian)
* [Fulcio](https://docs.sigstore.dev/fulcio/overview)
* [Certificate Log](https://docs.sigstore.dev/fulcio/certificate-issuing-overview)

An [NGINX](https://www.nginx.com) frontend is placed as an entrypoint to the various backend components. Communication is secured via a set of self-signed certificates that are generated at runtime.

Utilize the steps below to understand how to setup and execute the provisioning.

## Prerequisites

A RHEL 9.2+ server should be used to run the RHTAS components.

Ansible must be installed and configured on a control node that will be used to perform the automation.

Perform the following steps to prepare the control node for execution.

### Dependencies

Install the required Ansible collections by executing the following

```shell
ansible-galaxy collection install -r requirements.yml
```

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

In order to deploy RHTAS on a RHEL 9.2+ VM:

1. Create an `inventory` file with a single VM in the `rhtas` group:
  ```
  [rhtas]
  123.123.123.123 become=true
  ```
2. Create a simple Ansible playbook `play.yml`:
  ```
  - hosts: rhtas
    vars:
      base_hostname: TODO # e.g. example.com
      tas_single_node_oidc_issuers: TODO # your OIDC provider (e.g. keycloak) URL
      tas_single_node_issuer_url: TODO # your OIDC provider (e.g. keycloak) URL
    tasks:
      - name: Include TAS single node role
        ansible.builtin.include_role:
          name: tas_single_node
  ```
3. Execute the following command (NOTE: you will have to provide credentials to authenticate to registry.redhat.io: https://access.redhat.com/RegistryAuthentication):
  ```shell
  ANSIBLE_ROLES_PATH="roles/" ansible-playbook -i inventory play.yml -e registry_username='REGISTRY.REDHAT.IO_USERNAME' -e registry_password='REGISTRY.REDHAT.IO_PASSWORD'
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

1. Export the following environment variables substituting `BASE_HOSTNAME`, `KEYCLOAK_URL` and if necessary also `KEYCLOAK_REALM` with the values used as part of the provisioning:

```shell
export BASE_HOSTNAME="TODO-provide-base-hostname"
export KEYCLOAK_URL="TODO-your-keycloak-url"
export KEYCLOAK_REALM=trusted-artifact-signer

export TUF_URL=https://tuf.$BASE_HOSTNAME
export OIDC_ISSUER_URL=$KEYCLOAK_URL/auth/realms/$KEYCLOAK_REALM
export COSIGN_FULCIO_URL=https://fulcio.$BASE_HOSTNAME
export COSIGN_REKOR_URL=https://rekor.$BASE_HOSTNAME
export COSIGN_MIRROR=$TUF_URL
export COSIGN_ROOT=$TUF_URL/root.json
export COSIGN_OIDC_CLIENT_ID=$KEYCLOAK_REALM
export COSIGN_OIDC_ISSUER=$OIDC_ISSUER_URL
export COSIGN_CERTIFICATE_OIDC_ISSUER=$OIDC_ISSUER_URL
export COSIGN_YES="true"
export SIGSTORE_FULCIO_URL=$COSIGN_FULCIO_URL
export SIGSTORE_OIDC_ISSUER=$COSIGN_OIDC_ISSUER
export SIGSTORE_REKOR_URL=$COSIGN_REKOR_URL
export REKOR_REKOR_SERVER=$COSIGN_REKOR_URL
```

2. Initialize the TUF roots

```shell
cosign initialize
```

Note: If you have used `cosign` previously, you may need to delete the `~/.sigstore` directory

3. Sign the desired container

```shell
cosign sign -y <image>
```

Authenticate with the Keycloak instance using the desired credentials.

4. Verify the signed image

Refer to this example that verifies an image signed with email identity `sigstore-user@email.com` and issuer `https://github.com/login/oauth`.

```shell
cosign verify \
--certificate-identity-regexp sigstore-user \
--certificate-oidc-issuer-regexp keycloak  \
<image>
```

If the signature verification did not result in an error, the deployment of RHTAS was successful!

## Contributing

### Testing locally

This repository contains GitHub actions that will test PRs that come in with `ansible-lint` and `sanity-test` to enforce good code quality and practices. 

To run `ansible-lint` locally:

```shell
python3 -m venv venv
source venv/bin/activate
pip install -r requirements-testing.txt
ansible-lint
```

To run `sanity-test` locally:

The `ansible-test` command relies on a specific directory structure for collections to function correctly. This structure follows the format:

`{...}/ansible_collections/{namespace}/{collection}/`

To enable testing, make sure your local machine adheres to this format, which you can achieve by copying, symlinking, moving or cloning a repo into this structure.
`namespace` and `collection` names are not critical, as long as the overall format is kept, and no illegal characters are used such as `-`.
The `collection` refers to the current repository `artifact-signer-ansible`, while the namespace can be anything you want.

A valid path for our collection would be:
`{...}/ansible_collections/redhat/artifact_signer_ansible/`

When this is achieved, you can run sanity checks by executing

`ansible-test sanity`

### Testing Deployment on a VM

The [vm-testing/README.md](vm-testing/README.md) file contains instructions on testing the deployment on a VM. Right now, only OpenStack is supported as testing VM provisioner.

## Feedback

Any and all feedback is welcome. Submit an [Issue](https://github.com/securesign/artifact-signer-ansible/issues) or [Pull Request](https://github.com/securesign/artifact-signer-ansible/pulls) as desired.
