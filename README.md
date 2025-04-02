# Red Hat Trusted Artifact Signer Ansible collection

The purpose of this Ansible collection is to automate the deployment of the Red Hat Trusted Artifact Signer (RHTAS) service on Red Hat Enterprise Linux (RHEL).

## Description

The RHTAS service is the downstream redistribution of the [Sigstore](https://sigstore.dev) project.
The automation contained within this Git repository installs and configures the components of RHTAS to run on a single RHEL server, which uses a standalone containerized deployment.
A Kubernetes-based manifest creates containers that uses [`podman kube play`](https://docs.podman.io/en/latest/markdown/podman-kube-play.1.html).

The RHTAS Ansible collection deploys the following RHTAS components:

* [Rekor](https://docs.sigstore.dev/rekor/overview)
    * [Trillian database](https://github.com/google/trillian)
    * [Optional: A self-managed MariaDB instance, and a Redis instance](#configuring-a-user-provisioned-mariadb-and-redis-instance-for-the-rhtas-ansible-collection)
    
    **NOTE:** Highly recommended for production deployments to simplify operations and offload service management, including data backup and restoration.

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
* RHEL x86\_64 9.4 or greater.
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

Install the collection with the Ansible Galaxy command-line tool:

    ansible-galaxy collection install redhat.artifact_signer

You can also include it in a `requirements.yml` file and install it with `ansible-galaxy collection install -r requirements.yml`, using the format:

```yaml
collections:
  - name: redhat.artifact_signer
```

With Ansible Galaxy, upgrades are not automatically done when you upgrade the Ansible package.
To upgrade the collection to the latest available version, run the following command:

    ansible-galaxy collection install redhat.artifact_signer --upgrade

You can also install a specific version of the collection, for example, if you need to rollback to a earlier version.
Use the following syntax to install version 1.1.0:

    ansible-galaxy collection install redhat.artifact_signer:==1.1.0

**NOTE:** If you think you are experiencing a bug during installation, then open a GitHub [issue](https://github.com/securesign/artifact-signer-ansible/issues) for this project.

## Downloading CLI tools
To download the command-line tools for interacting with the Trusted Artifact Signer service, you can go to `https://cli-server.<base_hostname>`, where `<base_hostname>` is your deployment's base hostname.

## Verifying the deployment by signing a test container

On your workstation, export the following environment variables, replacing `TODO` with your relevant information:

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

Initialize The Update Framework (TUF) system:

    cosign initialize

**NOTE:** If you have used `cosign` before, you might need to delete the `~/.sigstore` directory first.

You can sign a test container image to verify the deployment of RHTAS by doing the following.
   
Create an empty container image:
      
    echo "FROM scratch" > ./tmp.Dockerfile
    podman build . -f ./tmp.Dockerfile -t ttl.sh/rhtas/test-image:1h

Push the empty container image to the `ttl.sh` ephemeral registry:
      
    podman push ttl.sh/rhtas/test-image:1h

Sign the container image:
      
    cosign sign -y ttl.sh/rhtas/test-image:1h

**NOTE:** A web browser opens allowing you to sign the container image with an email address.

Remove the temporary Docker file:

    rm ./tmp.Dockerfile

Verify the signed image by replacing `TODO` with the signer's email address:

    cosign verify --certificate-identity=TODO ttl.sh/rhtas/test-image:1h
   
If the signature verification does not result in an error, then the deployment of RHTAS was successful!

## Monitoring of containers with Cockpit
To monitor containers with Cockpit, you need to install the Red Hat Enterprise Linux System Roles Ansible Collection, found [here](https://console.redhat.com/ansible/automation-hub/repo/published/redhat/rhel_system_roles/) by using the following command:

    ansible-galaxy collection install redhat.rhel_system_roles:==1.88.9

**NOTE:** The minimum required version is 1.88.9.

Installing the system roles requires authentication with Ansible Automation Hub.
After installing the collection, you can enable and configure Cockpit by adding the following section to the playbook:

```yaml
tas_single_node_cockpit:
  enabled: true
  user:
    create: true
    username: cockpit-user
    password: password
```

**NOTE:** If you create a dedicated user for Cockpit, you might need to grant that user administrative access to view and interact with the pods.
To grant administrative access, click the **Limited Access** button in the upper-right corner of the Cockpit interface, and switch to administrative access.

## Use Cases

For single node deployments, create an `inventory` file with one node under the `rhtas` group:

    [rhtas]
    123.123.123.123

Create an Ansible Playbook named `play.yml`.
In the following example, replace `TODO` with your relevant information:

```yaml
    - hosts: rhtas
      vars:
        tas_single_node_base_hostname: TODO # e.g. example.com
        # Access credentials for registry.redhat.io (https://access.redhat.com/RegistryAuthentication).
        tas_single_node_registry_username: TODO
        tas_single_node_registry_password: TODO
        # Create secure unique passphrases.
        tas_single_node_fulcio:
          ca_passphrase: TODO
          fulcio_config:
            oidc_issuers:
              - issuer: TODO # Your OIDC provider URL
                client_id: trusted-artifact-signer
                url: TODO # Your OIDC provider URL
                type: email
          ct_log_prefix: TODO
        tas_single_node_ctlog:
          ca_passphrase: TODO
        tas_single_node_rekor:
          ca_passphrase: TODO
        tas_single_node_tsa:
          ca_passphrase: TODO
      tasks:
        - name: Include TAS single node role
          ansible.builtin.include_role:
            name: redhat.artifact_signer.tas_single_node # Use if deploying from Ansible Automation Hub.
          vars:
            ansible_become: true
```

**NOTE:** If you run this playbook from a locally-cloned Git repository, then replace the `redhat.artifact_signer.tas_single_node` value with `tas_single_node`.

Install the RHTAS Ansible collection:
   
**Option 1:** Install from Ansible Automation Hub by running the following command:
    
    ansible-playbook -i inventory play.yml

**Option 2:** Install from a locally-cloned Git repository by running the following command:
    
    export ANSIBLE_ROLES_PATH="roles/" ; ansible-playbook -i inventory play.yml

Add the root certificate authority (CA) to your local truststore:
  
    sudo openssl x509 -in ~/Downloads/root-cert-from-browser -out tas-ca.pem --outform PEM
    sudo mv tas-ca.pem /etc/pki/ca-trust/source/anchors/
    sudo update-ca-trust
    
**TIP:** Download the certificate from the Certificate Viewer by navigating to `https://rekor.<base_hostname>` in a web browser.
Download the _root_ certificate issued from the Rekor certificate.
   
**NOTE:** Add this certificate to all RHTAS client nodes that use the `cosign` and `gitsign` binaries for signing and verifying artifacts.

See [Ansible collections usage](https://docs.ansible.com/ansible/devel/user_guide/collections_using.html) for more details.

## Configuring a user-provisioned MariaDB and Redis instance for the RHTAS Ansible Collection
    
**Prerequisites:**

* An Amazon Web Services (AWS) account with the ability to create MariaDB and Elasticache Redis instances or equivalent.
* The RHTAS Ansible Collection installed and configured.

**Steps:**

Create a MariaDB instance.
Follow the MariaDB setup documentation for RHTAS found [here](https://docs.redhat.com/en/documentation/red_hat_trusted_artifact_signer/1/html/deployment_guide/configure-an-alternative-database-for-trusted-artifact-signer#configuring-amazon-rds-for-trusted-artifact-signer_deploy).
Ensure the instance uses the Trillian schema.
Make note the instance's hostname, port, username, password, and root's password.

Configure the Ansible collection.
Add the following to the installation playbook, `play.yml`:
            
```yaml
tas_single_node_trillian:
    database_deploy: false
    mysql:
        user: <username>
        root_password: <rootpassword>
        password: <password>
        database: <database_name>
        host: <hostname>
        port: <port>
```

Create a Redis instance:

* Follow the Amazon Web Services (AWS) [documentation](https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/GettingStarted.serverless-redis.step1.html) to create an Elasticache Redis instance or any other equivalent service provider.
* Note the instance's hostname, port, and password.

Reconfigure the Ansible collection.
Add the following to the installation playbook, `play.yml`:

```yaml
tas_single_node_rekor_redis:
    database_deploy: false
    redis:
    host: <hostname>
    port: <port>
    password: <password>
```

## Testing

### Testing locally

This Git repository has GitHub actions that tests incoming pull requests with `ansible-lint` and `sanity-test` to enforce good code quality and practices. 

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
By default, the VM provider is [Amazon Web Services](https://aws.amazon.com/).

## Contributing

## Support

You can open a support ticket for Red Hat Trusted Artifact Signer [here](https://access.redhat.com/support/cases/#/case/new?product=Red%20Hat%20Trusted%20Artifact%20Signer).

## Release notes and Roadmap

You can read the latest release notes [here](https://docs.redhat.com/en/documentation/red_hat_trusted_artifact_signer/1/html/release_notes/index).

## Related Information

For more documentation about Red Hat Trusted Artifact Signer, go [here](https://docs.redhat.com/en/documentation/red_hat_trusted_artifact_signer/1).

You can find information about Sigstore [here](https://www.sigstore.dev/).

## Feedback

Any and all feedback is welcome.
Submit an [Issue](https://github.com/securesign/artifact-signer-ansible/issues) or [Pull Request](https://github.com/securesign/artifact-signer-ansible/pulls) as needed.

## License Information

You can find the license information within the [LICENSE](LICENSE) file.
