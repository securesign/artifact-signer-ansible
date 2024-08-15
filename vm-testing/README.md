# VM testing

This directory contains tooling to (manually) test the collection on various cloud providers. As of now, only OpenStack is supported.

General prerequisites:
```
dnf install opentofu      # Install OpenTofu
python3 -m venv venv      # Create a Python virtualenv
source venv/bin/activate  # Activate the virtualenv in current shell
pip install ansible       # Install Ansible
```

## OpenStack

### First time setup

Before starting, you will need to:
* Get an API token for your OpenStack instance according to the [docs](https://docs.openstack.org/api-quick-start/api-quick-start.html). *Note that the token has an expiration date and needs to be refreshed when it expires.*
* Create an SSH keypair at `/dashboard/project/key_pairs` page of you OpenStack instance.
* Switch images from `registry.redhat.io` images to the dev images by running 
`sed -f vm-testing/dev-images.sed  -i roles/tas_single_node/defaults/main.yml`

When you have the above, create an `openstack/terraform.tfvars` file with following contents:

```
openstack_user_name = "TODO-user-name"
openstack_domain_name = "TODO-domain"
openstack_token = "TODO-api-token"
# Auth URL can be accessed at /dashboard/project/api_access/ (click "View Credentials", look for "Authentication URL")
openstack_auth_url = "TODO-openstack-auth-url"
# Tenant name can be accessed at /dashboard/project/api_access/ (click "View Credentials", look for "Project Name")
openstack_tenant_name = TODO-tenant""
openstack_ssh_key_pair = "TODO-ssh-key-pair"
# Network can be e.g. shared_net_*
openstack_network = "TODO-openstack-network"
# Optionally provide a custom VM image
# openstack_vm_image = "TODO-vm-image"
```

Create `vars.yml` file with the following variables for the `tas_single_node` role (you will need a working OIDC provider URL, e.g. Keycloak, with a `trusted-artifact-signer` realm):

```
# Get registry credentials at https://access.redhat.com/terms-based-registry
tas_single_node_registry_username: "TODO-username"
tas_single_node_registry_password: "TODO-password"
tas_single_node_oidc_issuers: "TODO-issuer-url"
tas_single_node_issuer_url: "TODO-issuer-url"
```

### Provisioning the VM and running Ansible

When testing, you can:

* Provision a new machine by running `./provision.sh openstack`. This will:
  * Provision a new OpenStack VM.
  * Print a command to modify `/etc/hosts` on your localhost to add URLs to services you're about to deploy - inspect the command and run it.
  * Create a properly configured `inventory` file.
* Run `ansible-playbook play.yml` to deploy RHTAS to your VM. You can modify in play.yml/vars.yml to e.g. change configuration.
* Destroy the VM by running `./destroy.sh openstack`. This will:
  * Destroy the VM.
  * Print a command to remove the entries from `/etc/hosts` - inspect the command and run it.

## Testing

You can run a simple test that signs a blob in a container by running `./test.sh`. Note that this must be run in the Python virtualenv environment created in the start to work properly.
