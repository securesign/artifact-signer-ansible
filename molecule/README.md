# Molecule Testing

This directory contains tests that run using [Ansible Molecule](https://ansible.readthedocs.io/projects/molecule/). By default, [testing-farm](https://docs.testing-farm.io/) is used as the VM provider.

## Using Molecule

### Setup

First of all, create a local Python virtualenv and install molecule and dependencies. In the root directory of this repository, run:

```shell
python3 -m venv venv
source venv/bin/activate
pip3 install -r requirements-testing.txt
ansible-galaxy install -r requirements.yml
ansible-galaxy install -r molecule/requirements.yml
```

Next, export following values in your shell environment:

```
export TAS_SINGLE_NODE_REGISTRY_USERNAME=<your-username-for-registry.redhat.io>
export TAS_SINGLE_NODE_REGISTRY_PASSWORD=<your-password-for-registry.redhat.io>
# get this from the Testing Farm team
export TESTING_FARM_API_TOKEN=<your-testing-farm-token>
```

Last, ask the Testing Farm team to allow your IP to run Molecule tests (run `curl icanhazip.com` to get your IP address).

### Usage

Molecule has [multiple commands](https://ansible.readthedocs.io/projects/molecule/usage/#molecule-list). The most important are:

* `molecule create` - creates the VM and stops
* `molecule destroy` - destroys the VM and stops
* `molecule reset` - wipe out locally cached data about created VMs without destroying them
* `molecule verify` - run verification steps on a provisioned VM
* `molecule converge` - runs `create` (skips if VM is already created) and then converges (applies `molecule/<scenario>/converge.yml` which applies the role)
* `molecule idempotence` - converges twice; fails if there are `changed` tasks on the second run
* `molecule test` - runs `converge`, `idempotence`, `verify` and `destroy`

When doing local development, it's most useful to run `molecule converge` until your feature works fine and then run full `molecule test` on a clean VM to ensure everything is correct.

Note that each of the above commands can be followed by scenario name, e.g. `molecule converge <scenario>` to test a specific scenario (`default` is the default scenario). Scenarios are subdirectories of this directory.

## Testing Farm/Molecule integration specifics

Testing Farm VMs expire and are destroyed automatically after a period of time (Testing Farm default is 30 minutes). This can be changed in the `molecule.yml` of an individual scenario (e.g. `molecule/default/molecule.yml`). To change this value, set the `duration` attribute of a `platforms` item to number of minutes after which the VM will be destroyed.

When a VM expires, you have to run `molecule reset` to remove locally cached information about it and start over.

## Using a different VM provider

In order to use a different VM provider, one would have to replace the `molecule/<scenario>/create.yml` and `molecule/<scenario>/destroy.yml` and/or provide an [existing molecule provider](https://github.com/ansible-community/molecule-plugins) in `molecule/<scenario>/molecule.yml`.
