# Red Hat Trusted Artifact Signer Ansible collection

The purpose of this Ansible collection is to automate the deployment of the Red Hat Trusted Artifact Signer (RHTAS) service on Red Hat Enterprise Linux (RHEL).

> [!IMPORTANT]
Deploying RHTAS by using Ansible is a Technology Preview feature only.
Technology Preview features are not supported with Red Hat production service level agreements (SLAs), might not be functionally complete, and Red Hat does not recommend to use them for production.
These features provide early access to upcoming product features, enabling customers to test functionality and provide feedback during the development process.
See the support scope for [Red Hat Technology Preview](https://access.redhat.com/support/offerings/techpreview/) features for more details.

## Description

The RHTAS service is the downstream redistribution of the [Sigstore](https://sigstore.dev) project.
The automation contained within this Git repository installs and configures the components of RHTAS to run on a single RHEL server, which uses a standalone containerized deployment.
A Kubernetes-based manifest creates containers that uses [`podman kube play`](https://docs.podman.io/en/latest/markdown/podman-kube-play.1.html).

The RHTAS Ansible collection deploys the following RHTAS components:

* [Rekor](https://docs.sigstore.dev/rekor/overview)
  * [Trillian database](https://github.com/google/trillian)
  * Optional: A self-managed MariaDB instance, and a Redis instance.
* [Fulcio](https://docs.sigstore.dev/fulcio/overview)
* [Certificate Log](https://docs.sigstore.dev/fulcio/certificate-issuing-overview)
* [Timestamp Authority](https://docs.sigstore.dev/verifying/timestamps/#timestamp-authorities)
* [The Update Framework (TUF) server](https://theupdateframework.io/)

An [NGINX](https://www.nginx.com) front end places an entrypoint to the various backend components.
A set of self-signed certificates get generated at runtime to establishing secure communications.

This automation also deploys and configures a software load balancer as a central point of ingress.
The ingress host names are as follows, where `<base_hostname>` is your deployment's base hostname:

* https://cli-server.`<base_hostname>`
* https://fulcio.`<base_hostname>`
* https://rekor.`<base_hostname>`
* https://rekor-search.`<base_hostname>`
* https://tsa.`<base_hostname>`
* https://tuf.`<base_hostname>`

## Requirements

* Ansible 2.16.0 or greater
* Python 3.9.0 or greater
* RHEL x86\_64 9.2 or greater.
* All client nodes using `cosign`, `gitsign`, and `ec` need the following:
  * Command-line access to the node with a user that has `sudo` privileges.
  * Updated DNS records or `/etc/hosts` entries with the ingress host names and IP addresses.
* Installation and configuration of Ansible on a control node to perform the automation.
* Installation of the Ansible collections on the control node.
  * If installing from the Ansible Automation Hub, then run `ansible-galaxy install redhat.artifact_signer`.
  * If installing from this Git repository, then clone it locally, and run `ansible-galaxy collection install -r requirements.yml`.
* An OpenID Connect (OIDC) provider, such as [Keycloak](https://console.redhat.com/ansible/automation-hub/repo/published/redhat/sso/).
* The ability to resolve the ingress host names, by using the Domain Name System (DNS) or the `/etc/hosts` file.
* Optional:
  Installation of the `podman` and [`cosign`](https://github.com/sigstore/cosign) binaries to verify that the RHTAS service is working as expected.

## Installation


Before using this collection, you need to install it with the Ansible Galaxy command-line tool:

    ansible-galaxy collection install redhat.artifact_signer

You can also include it in a `requirements.yml` file and install it with `ansible-galaxy collection install -r requirements.yml`, using the format:


```yaml
---
collections:
  - name: redhat.artifact_signer
```

Note that if you install any collections from Ansible Galaxy, they will not be upgraded automatically when you upgrade the Ansible package.
To upgrade the collection to the latest available version, run the following command:

    ansible-galaxy collection install redhat.artifact_signer --upgrade

You can also install a specific version of the collection, for example, if you need to downgrade when something is broken in the latest version (please report an issue in this repository). Use the following syntax to install version 1.1.0:

    ansible-galaxy collection install redhat.artifact_signer:==1.1.0


## Downloading CLI tools
   To Download tools to interact with Red Hat Trusted Artifact Signer, you can visit `https://cli-server.<base_hostname>`

## Verifying the deployment by signing a test container

1. Export the following environment variables, replacing `TODO` with your relevant information:

   ```text
   export BASE_HOSTNAME="TODO"
   export KEYCLOAK_URL="TODO"
   export KEYCLOAK_REALM=TODO
  
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

2. Initialize The Update Framework (TUF) system:

        cosign initialize

   > [!NOTE]
   If you have used `cosign` before, you might need to delete the `~/.sigstore` directory first.

3. Sign a test container image.
   
   a. Create an empty container image:
      
        echo "FROM scratch" > ./tmp.Dockerfile
        podman build . -f ./tmp.Dockerfile -t ttl.sh/rhtas/test-image:1h

   b. Push the empty container image to the `ttl.sh` ephemeral registry:
      
        podman push ttl.sh/rhtas/test-image:1h

   c. Sign the container image:
      
        cosign sign -y ttl.sh/rhtas/test-image:1h

      A web browser opens allowing you to sign the container image with an email address.

   d. Remove the temporary Docker file:
      
        rm ./tmp.Dockerfile

4. Verify the signed image by replacing `TODO` with the signer's email address:

        cosign verify --certificate-identity=TODO ttl.sh/rhtas/test-image:1h
   
   If the signature verification does not result in an error, then the deployment of RHTAS was successful!

## Use Cases

See [using Ansible collections](https://docs.ansible.com/ansible/devel/user_guide/collections_using.html) for more details.



1. Create an `inventory` file with a single node under the `rhtas` group:
   
   ```yaml
   ---
   [rhtas]
   123.123.123.123
   ```

2. Create an Ansible Playbook named `play.yml`, and replace `TODO` with your relevant information:
   
   ```yaml
   ---
   - hosts: rhtas
     vars:
       base_hostname: TODO # e.g. example.com
       # access credentials for registry.redhat.io (https://access.redhat.com/RegistryAuthentication)
       tas_single_node_registry_username: TODO
       tas_single_node_registry_password: TODO
       tas_single_node_oidc_issuers:
         - issuer: TODO # your OIDC provider (e.g. keycloak) URL
           client_id: trusted-artifact-signer
           url: TODO # your OIDC provider (e.g. keycloak) URL
           type: email
     tasks:
       - name: Include TAS single node role
         ansible.builtin.include_role:
           name: redhat.artifact_signer.tas_single_node # Use if deploying from Ansible Automation Hub.
         vars:
           ansible_become: true
   ```
   > [!NOTE]
   If running this Playbook from a locally-cloned Git repository, then replace the `redhat.artifact_signer.tas_single_node` value with `tas_single_node`.

3. Install the RHTAS Ansible collection.
   
   - If installing from Ansible Automation Hub, then run the following command:
   
        ansible-playbook -i inventory play.yml

   - If running from a locally-cloned Git repository, then run the following command:
   
        export ANSIBLE_ROLES_PATH="roles/" ; ansible-playbook -i inventory play.yml

4. Add the root certificate authority (CA) to your local truststore:
  
        sudo openssl x509 -in ~/Downloads/root-cert-from-browser -out tas-ca.pem --outform PEM
        sudo mv tas-ca.pem /etc/pki/ca-trust/source/anchors/
        sudo update-ca-trust

   > [!TIP]
   The certificate can be downloaded from the Certificate Viewer by navigating to `https://rekor.<base_hostname>` in a web browser.
   Download the _root_ certificate that issued the Rekor certificate.
   
   > [!NOTE]
   Add this certificate to all RHTAS client nodes that use the `cosign` and `gitsign` binaries for signing and verifying artifacts.

## Testing

### Testing locally

This Git repository has GitHub actions that tests incoming PRs with `ansible-lint` and `sanity-test` to enforce good code quality and practices. 

To run `ansible-lint` locally:

        python3 -m venv venv
        source venv/bin/activate
        pip install -r testing-requirements.txt
        ansible-lint

To run `sanity-test` locally:

The `ansible-test` command relies on a specific directory structure for collections to function correctly.
This structure follows the format, `{...}/ansible_collections/{namespace}/{collection}/`.

To enable testing, make sure your local machine adheres to this format, which you can achieve by copying, symlinking, moving or cloning a Git repository into this structure.
By keeping the overall format, and not using invalid characters, such as `-`, the `namespace` and `collection` names are not critical.
The `collection` refers to the current repository `artifact-signer-ansible`, while the `namespace` can be anything you want.

A valid path for our collection would be, `{...}/ansible_collections/redhat/artifact_signer_ansible/`.

To achieve this, you can run sanity checks by running the following:

        ansible-test sanity

### Testing Deployment on a virtual machine

The [molecule/README.md](molecule/README.md) file has instructions on testing the deployment on a virtual machine (VM).
By default, the VM provider is [testing-farm.io](https://docs.testing-farm.io/).

## Contributing

## Support

Support tickets for RedHat Trusted Artifact Signer can be opened at https://access.redhat.com/support/cases/#/case/new?product=Red%20Hat%20Trusted%20Artifact%20Signer.

## Release notes and Roadmap

Release notes can be found [here](https://docs.redhat.com/en/documentation/red_hat_trusted_artifact_signer/1.1/html/release_notes/index).

## Related Information

More information around Red Hat Trusted Artifact Signer can be found [here](https://docs.redhat.com/en/documentation/red_hat_trusted_artifact_signer/1).

Information on Sigstore can be found [here](https://www.sigstore.dev/).

## Feedback

Any and all feedback is welcome.
Submit an [Issue](https://github.com/securesign/artifact-signer-ansible/issues) or [Pull Request](https://github.com/securesign/artifact-signer-ansible/pulls) as needed.

## License Information

License Information cna be found within the [LICENSE](LICENSE) file.
