<!--- to update this file, update files in the role's meta/ directory (and/or its README.j2 template) and run "make role-readme" -->
# Ansible Role: redhat.artifact_signer.tas_single_node
Version: 1.0.0

The `tas_single_node` role can be used to deploy a [RHTAS](https://docs.redhat.com/en/documentation/red_hat_trusted_artifact_signer) instance on a single managed node.
 Requires RHEL >= 9.2.

## Role Arguments
### Required
|Option|Description|Type|Default|
|---|---|---|---|
| tas_single_node_registry_username | Login for registry where the images will be pulled from | str |  |
| tas_single_node_registry_password | Password for registry where the images will be pulled from | str |  |
| tas_single_node_base_hostname | Base hostname of the managed node. This will be used to generate proper self-signed certificates for the individual HTTPS endpoints. | str |  |
| tas_single_node_oidc_issuers | List of OIDC issuers to allow to authenticate Fulcio certificate requests | list of dicts of 'tas_single_node_oidc_issuers' options |  |

### Optional
|Option|Description|Type|Default|
|---|---|---|---|
| tas_single_node_podman_network | Name of the podman network for the containers to use | str |  `rhtas`  |
| tas_single_node_rekor_redis | Details of Redis connection for Rekor (set this to provide custom Redis instance) | dict of 'tas_single_node_rekor_redis' options |  `{"database_deploy": true, "redis": {"host": "rekor-redis-pod", "port": 6379, "password": "password"}}`  |
| tas_single_node_trillian | Details of database connection for Trillian (set this to provide custom MySQL/MariaDB instance) | dict of 'tas_single_node_trillian' options |  `{"database_deploy": true, "mysql": {"user": "mysql", "root_password": "rootpassword", "password": "password", "database": "trillian", "host": "trillian-mysql-pod", "port": 3306}}`  |
| tas_single_node_rekor_public_key_retries | Number of retries when retrieving Rekor public key when constructing trust root | int |  `5`  |
| tas_single_node_rekor_public_key_delay | Number of seconds to wait before retrying retrieval of Rekor public key when constructing trust root | int |  `10`  |
| tas_single_node_setup_host_dns | Set up managed host DNS to resolve URLs of the configured RHTAS services | bool |  `true`  |
| tas_single_node_kms_key_resource | KMS key for signing timestamp responses. Valid options include: [gcpkms://resource, azurekms://resource, hashivault://resource, awskms://resource] | str |  |
| tas_single_node_tink_key_resource | KMS key for signing timestamp responses for Tink keysets. Valid options include: [gcp-kms://resource, aws-kms://resource, hcvault://] | str |  |
| tas_single_node_tsa_tink_keyset | KMS-encrypted keyset for Tink, decrypted by tas_single_node_tink_key_resource | str |  |
| tas_single_node_tink_hcvault_token | Authentication token for Hashicorp Vault API calls | str |  |
| tas_single_node_skip_os_install | Skip installation of required OS packages. Only use this when all packages are already installed at versions released for RHEL >= 9.2 | bool |  `false`  |
| tas_single_node_meta_issuers | List of OIDC meta issuers to allow to authenticate Fulcio certificate requests | list of dicts of 'tas_single_node_meta_issuers' options |  |
| tas_single_node_fulcio_server_image | Fulcio image | str |  `registry.redhat.io/rhtas/fulcio-rhel9@sha256:67495de82e2fcd2ab4ad0e53442884c392da1aa3f5dd56d9488a1ed5df97f513`  |
| tas_single_node_trillian_log_server_image | Trillian log server image | str |  `registry.redhat.io/rhtas/trillian-logserver-rhel9@sha256:994a860e569f2200211b01f9919de11d14b86c669230184c4997f3d875c79208`  |
| tas_single_node_logsigner_image | Trillian logsigner image | str |  `registry.redhat.io/rhtas/trillian-logsigner-rhel9@sha256:37028258a88bba4dfaadb59fc88b6efe9c119a808e212ad5214d65072abb29d0`  |
| tas_single_node_rekor_image | Rekor image | str |  `registry.redhat.io/rhtas/rekor-server-rhel9@sha256:133ee0153e12e6562cfea1a74914ebdd7ee76ae131ec7ca0c3e674c2848150ae`  |
| tas_single_node_ct_server_image | CTLog image | str |  `registry.redhat.io/rhtas/certificate-transparency-rhel9@sha256:a0c7d71fc8f4cb7530169a6b54dc3a67215c4058a45f84b87bb04fc62e6e8141`  |
| tas_single_node_redis_image | Redis image | str |  `registry.redhat.io/rhtas/trillian-redis-rhel9@sha256:01736bdd96acbc646334a1109409862210e5273394c35fb244f21a143af9f83e`  |
| tas_single_node_trillian_db_image | Trillian database image | str |  `registry.redhat.io/rhtas/trillian-database-rhel9@sha256:909f584804245f8a9e05ecc4d6874c26d56c0d742ba793c1a4357a14f5e67eb0`  |
| tas_single_node_tuf_image | TUF server image | str |  `registry.redhat.io/rhtas/tuf-server-rhel9@sha256:34f5cdc53a908ae2819d85ab18e35b69dc4efc135d747dd1d2e216a99a2dcd1b`  |
| tas_single_node_netcat_image | Netcat image | str |  `registry.redhat.io/openshift4/ose-tools-rhel8@sha256:486b4d2dd0d10c5ef0212714c94334e04fe8a3d36cf619881986201a50f123c7`  |
| tas_single_node_nginx_image | Nginx image | str |  `registry.redhat.io/rhel9/nginx-124@sha256:71fc4492c3a632663c1e17ec9364d87aa7bd459d3c723277b8b94a949b84c9fe`  |
| tas_single_node_tsa_image | Timestamp Authority Image | str |  `registry.redhat.io/rhtas/timestamp-authority-rhel9@sha256:3fba2f8cd09548d2bd2dfff938529952999cb28ff5b7ea42c1c5e722b8eb827f`  |
| tas_single_node_rekor_search_image | Rekor search UI image | str |  `registry.redhat.io/rhtas/rekor-search-ui-rhel9@sha256:8c478fc6122377c6c9df0fddf0ae42b6f6b1648e3c6cf96a0558f366e7921b2b`  |

#### Options for main > tas_single_node_rekor_redis

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| database_deploy | Whether or not to deploy Redis | bool | no |  `false`  |
| redis | Details of Redis connection | dict of 'redis' options | no |  |

#### Options for main > tas_single_node_rekor_redis > redis

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| host | Redis host | str | no |  |
| port | Redis host port | int | no |  |
| password | Redis password | str | no |  |

#### Options for main > tas_single_node_trillian

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| database_deploy | Whether or not to deploy the database | bool | no |  `false`  |
| mysql | Details of database connection | dict of 'mysql' options | no |  |

#### Options for main > tas_single_node_trillian > mysql

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| host | Database host | str | no |  |
| port | Database host port | int | no |  |
| password | Database password | str | no |  |
| user | Database user | str | no |  |
| root_password | Root password for the database | str | no |  |
| database | Database to connect to | str | no |  |

#### Options for main > tas_single_node_oidc_issuers

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| issuer | Unique name of the OIDC issuer | str | yes |  |
| url | OIDC issuer service URL | str | yes |  |
| client_id | OIDC client ID to use by this RHTAS instance | str | yes |  |
| type | Type of the OIDC token issuer, e.g. 'email' | str | yes |  |

#### Options for main > tas_single_node_meta_issuers

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| issuer_pattern | Templated URL to match multiple OIDC issuers, e.g. `'https://oidc.eks.*.amazonaws.com/id/*'` | str | yes |  |
| client_id | OIDC client ID to use by this RHTAS instance | str | yes |  |
| type | Type of the OIDC token issuer, e.g. `'email'` | str | yes |  |

## Example Playbook

```
- hosts: rhtas
  vars:
    tas_single_node_registry_username: # TODO: required, type: str
    tas_single_node_registry_password: # TODO: required, type: str
    tas_single_node_base_hostname: # TODO: required, type: str
    tas_single_node_oidc_issuers: # TODO: required, type: list
    
  tasks:
    - name: Include TAS single node role
      ansible.builtin.include_role:
        name: redhat.artifact_signer.tas_single_node
      vars:
        ansible_become: true
```

## License

Apache-2.0

## Author and Project Information

Red Hat
