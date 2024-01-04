# sigstore-ansible

Automation to deploy the sigstore ecosystem on RHEL

:warning: **The contents of this repository are a Work in Progress.**

## Overview

The automation within this repository establishes the components of the [Sigstore project](https://sigstore.dev) within a single
Red Hat Enterprise Linux (RHEL) machine using a standalone containerized deployment.
Containers are spawned using Kubernetes based manifests using
[podman kube play](https://docs.podman.io/en/latest/markdown/podman-kube-play.1.html).

The following Sigstore components are deployed as part of this architecture:

* [Rekor](https://docs.sigstore.dev/rekor/overview)
    * [Trillian](https://github.com/google/trillian)
* [Fulcio](https://docs.sigstore.dev/fulcio/overview)
* [Certificate Log](https://docs.sigstore.dev/fulcio/certificate-issuing-overview)
* [Keycloak](https://www.keycloak.org)

An [NGINX](https://www.nginx.com) frontend is placed as an entrypoint to the various backend components. Communication is secured via a set of self-signed certificates that are generated at runtime.

[Keycloak](https://www.keycloak.org) is being used as a OIDC issuer for facilitating keyless signing.

Utilize the steps below to understand how to setup and execute the provisioning.

## Prerequisites

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

### Keycloak

Keycloak is deployed to enable keyless (OIDC) signing. A dedicated realm called `sigstore` is configured by default using a client called `sigstore`

To be able to sign containers, you will need to authenticate to the Keycloak instance. By default, a single user (jdoe) is created. This can be customized by specifying the `keycloak_sigstore_users` variable. The default value is shown below and can be used to authenticate to Keycloak if no modifications are made:

```yaml
keycloak_sigstore_users:
 - username: jdoe
   first_name: John
   last_name: Doe
   email: jdoe@redhat.com
   password: mysecurepassword
```

### Ingress

The automation deploys and configures a software load balancer as a central point of ingress. Multiple hostnames underneath a _base hostname_ are configured and include the following hostnames:

* https://rekor.<base_hostname>
* https://fulcio.<base_hostname>
* https://keycloak.<base_hostname>
* https://tuf.<base_hostname>

Each of these hostnames must be configured in DNS to resolve to the target machine. The `base_hostname` parameter must be provided
when executing the provisining. To configure hostnames in DNS, edit `/etc/hosts` with the following content:

```
<REMOTE IP ADDRESS> keycloak.<base_hostname>
<REMOTE_IP_ADDRESS> fulcio.<base_hostname> fulcio
<REMOTE_IP_ADDRESS> rekor.<base_hostname> rekor
<REMOTE_IP_ADDRESS> tuf.<base_hostname> tuf
```

### Cosign

[cosign](https://github.com/sigstore/cosign) is used as part of testing and validating the setup and configuration. It is an optional install if there is not a desire to perform the validation as described below.

## Provision

Execute the following commands to execute the automation:

```shell
# Run the playbook from your local system
ansible-playbook -vv -i inventory playbooks/install.yml -e base_hostname=sigstore-dev.ez -K
```

### Add the root CA that was created to your local truststore.

The certificate can be downloaded from the browser Certificate Viewer by navigating to `https://rekor.<base_domain>`.
Download the _root_ certiicate that issued the rekor certificate.
In Red Hat based systems, the following commands will add a CA to the system truststore.

```shell
$ sudo openssl x509 -in ~/Downloads/root-cert-from-browser -out sigstore-ca.pem --outform PEM
$ sudo mv sigstore-ca.pem /etc/pki/ca-trust/source/anchors/
$ sudo update-ca-trust
```

## Signing a Container

Utilize the following steps to sign a container that has been published to an OCI registry

1. Export the following environment variables substituting `base_hostname` with the value used as part of the provisioning

```shell
export KEYCLOAK_REALM=sigstore
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

## Terraform
Terraform code is included within this repository it assumes that you have SSH keys defined at `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`, the terraform binary is installed, and that you have an AWS account. Credentials for the AWS account are set using the [AWS cli and following these steps](https://docs.aws.amazon.com/cli/latest/reference/configure/index.html) Run time variables exist if this path is not applicable to your sytstem and can be provided through a terraform variable file or providing the variables at the `terraform apply` step. To test the functionality run the following.

NOTE: You will be prompted to provide the base domain and vpc at launch time.

```
terraform init
terraform apply --auto-approve
```

If you need to remove the assets run the following to ensure you are starting clean.

```
git checkout inventory && rm -f aws_keys_pairs.pem && terraform destroy --auto-approve
```

If you are consistently tesing with the terraform code a variable file can be used to save time.

`terraform.tfvars`
```
vpc_id = "EXAMPLE"
base_domain = "EXAMPLE"
rh_username = "EXAMPLE"
rh_password = "EXAMPLE"
ssh_public_key_path = "~/example/.ssh/id_rsa.pub"
ssh_private_key_path = "~/example/.ssh/id_rsa"
```

With this file defined the following can be ran 
```
terraform apply --auto-approve --var-file='terraform.tfvars'
```


## Testing
The following assumes that cosign has been installed on the system

NOTE: Replace `octo-emerging.redhataicoe.com` with your base domain.
```
export BASE_HOSTNAME=octo-emerging.redhataicoe.com && export ESCAPED_URL=octo-emerging_redhataicoe_com && rm -rf ./*.pem && openssl s_client -showcerts -verify 5 -connect rekor.$BASE_HOSTNAME:443 < /dev/null |    awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/{ if(/BEGIN CERTIFICATE/){a++}; out="cert"a".pem"; print >out}' && for cert in *.pem; do newname=$(openssl x509 -noout -subject -in $cert | sed -nE 's/.*CN ?= ?(.*)/\1/; s/[ ,.*]/_/g; s/__/_/g; s/_-_/-/; s/^_//g;p' | tr '[:upper:]' '[:lower:]').pem;         echo "${newname}"; mv "${cert}" "${newname}" ; done && sudo mv $ESCAPED_URL.pem /etc/pki/ca-trust/source/anchors/ && sudo update-ca-trust && export KEYCLOAK_REALM=sigstore && export FULCIO_URL=https://fulcio.$BASE_HOSTNAME && export KEYCLOAK_URL=https://keycloak.$BASE_HOSTNAME && export REKOR_URL=https://rekor.$BASE_HOSTNAME && export TUF_URL=https://tuf.$BASE_HOSTNAME && export KEYCLOAK_OIDC_ISSUER=$KEYCLOAK_URL/realms/$KEYCLOAK_REALM && cosign initialize --mirror=$TUF_URL --root=$TUF_URL/root.json
```

Next, ensure that an image has been tagged with your quay repository and run the following. For this example, the image `quay.io/rcook/tools:awxy-runner2` is used.

```
cosign sign -y --fulcio-url=$FULCIO_URL --rekor-url=$REKOR_URL --oidc-issuer=$KEYCLOAK_OIDC_ISSUER  quay.io/rcook/tools:awxy-runner2
```

## Feedback

Any and all feedback is welcomed. Submit an [Issue](https://github.com/securesign/sigstore-ansible/issues) or [Pull Request](https://github.com/securesign/sigstore-ansible/pulls) as desired.
