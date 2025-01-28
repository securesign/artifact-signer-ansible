# Molecule Testing

This directory contains tests that run using [Ansible Molecule](https://ansible.readthedocs.io/projects/molecule/). By default, [AWS EC2](https://aws.amazon.com/ec2/) is used as the VM provider.

## Using Molecule

### Setup

First of all, create a local Python virtualenv and install molecule and dependencies. In the root directory of this repository, run:

```shell
python3 -m venv venv
source venv/bin/activate
pip3 install -r testing-requirements.txt
ansible-galaxy install -r requirements.yml
ansible-galaxy install -r molecule/requirements.yml  
```

Next, export following values in your shell environment:

```
export TAS_SINGLE_NODE_REGISTRY_USERNAME=<your-username-for-registry.redhat.io>
export TAS_SINGLE_NODE_REGISTRY_PASSWORD=<your-password-for-registry.redhat.io>
```

Install and configure the AWS CLI tool on your local machine. You will need to contact the AWS groups administrator to create an IAM user with power user privileges.
Use the provided user credentials to log in to AWS CLI locally. Create a keypair for SSH access to VMs, you can also add the key pair to your SSH agent using `ssh-add`.
Configure the `aws_key_name` variable in `molecule.yml` to point to your key pair.

### Usage

Molecule has [multiple commands](https://ansible.readthedocs.io/projects/molecule/usage/#molecule-list). The most important are:

* `molecule create` - creates the VM and stops
* `molecule destroy` - destroys the VM and stops
* `molecule reset` - wipe out locally cached data about created VMs without destroying them
* `molecule converge` - runs `create` (skips if VM is already created) and then converges (applies `molecule/<scenario>/converge.yml` which applies the role)
* `molecule verify` - run verification steps on a provisioned VM (expects that you already converged it)
* `molecule idempotence` - converges twice; fails if there are `changed` tasks on the second run
* `molecule test` - runs `converge`, `idempotence`, `verify` and `destroy`

When doing local development, it's most useful to run `molecule converge` until your feature works fine and then run full `molecule test` on a clean VM to ensure everything is correct.

Note that each of the above commands can be followed by scenario name, e.g. `molecule converge <scenario>` to test a specific scenario (`default` is the default scenario). Scenarios are subdirectories of this directory.

## AWS EC2 integration specifics

AWS EC2 VMs expire and are destroyed automatically after a period of time (Pruned around midnight daily). Any infrastructure set up to allow for an EC2 instance to work is also pruned, but the molecule create command sets everything up again if they were deleted.

If you are having issues adding the vm to known hosts, you need to manually prune all infrastructure in the aws console, then run molecule create again which will set up a fresh infrastructure ready to use.

When a VM expires or is pruned, you have to run `molecule reset` to remove locally cached information about it and start over.

## Using a different VM provider

In order to use a different VM provider, one would have to replace the `molecule/<scenario>/create.yml` and `molecule/<scenario>/destroy.yml` and/or provide an [existing molecule provider](https://github.com/ansible-community/molecule-plugins) in `molecule/<scenario>/molecule.yml`.
