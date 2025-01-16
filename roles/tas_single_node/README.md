<!--- to update this file, update files in the role's meta/ directory (and/or its README.j2 template) and run "make role-readme" -->
# Ansible Role: redhat.artifact_signer.tas_single_node
Version: 1.1.0

Deploy the [RHTAS](https://docs.redhat.com/en/documentation/red_hat_trusted_artifact_signer) service on a single managed node by using the `tas_single_node` role.
 Requires RHEL 9.2 or later.

## Role Arguments
### Required
|Option|Description|Type|Default|
|---|---|---|---|
| tas_single_node_registry_username | The user name logging in to the registry to pull images. | str |  |
| tas_single_node_registry_password | The user's password to log in to the registry. | str |  |
| tas_single_node_base_hostname | The base host name of the managed node. This generates self-signed certificates for the individual HTTPS endpoints. | str |  |
| tas_single_node_oidc_issuers | The list of OpenID Connect (OIDC) issuers allowed to authenticate Fulcio certificate requests. | list of dicts of 'tas_single_node_oidc_issuers' options |  |

### Optional
|Option|Description|Type|Default|
|---|---|---|---|
| tas_single_node_podman_network | Name of the Podman network for containers to use. | str |  `rhtas`  |
| tas_single_node_rekor_redis | Details on the Redis connection for Rekor. You can set this to a custom Redis instance. | dict of 'tas_single_node_rekor_redis' options |  `{'database_deploy': True, 'redis': {'host': 'rekor-redis-pod', 'port': 6379, 'password': 'password'}}`  |
| tas_single_node_trillian | Details on the database connection for Trillian. You can set this to a custom MySQL or MariaDB instance. | dict of 'tas_single_node_trillian' options |  `{'database_deploy': True, 'mysql': {'user': 'mysql', 'root_password': 'rootpassword', 'password': 'password', 'database': 'trillian', 'host': 'trillian-mysql-pod', 'port': 3306}}`  |
| tas_single_node_fulcio | Details on the certificate settings for Fulcio. Includes organizational details, the user-provided private key for signing the root certificate, and the user-provided root certificate itself. | dict of 'tas_single_node_fulcio' options |  `{'certificate': {'organization_name': '', 'organization_email': '', 'common_name': ''}, 'tas_single_node_fulcio_private_key': '', 'tas_single_node_fulcio_root_ca': ''}`  |
| tas_single_node_fulcio_private_key | Private key for Fulcio, used for signing root certificate. | str |  |
| tas_single_node_fulcio_root_ca | The root certificate for Fulcio. | str |  |
| tas_single_node_rekor_public_key_retries | The number of attempts to retrieve the Rekor public key when constructing the trust root. | int |  `5`  |
| tas_single_node_rekor_public_key_delay | The number of seconds to wait before retrying the retrieval of the Rekor public key when constructing the trust root. | int |  `10`  |
| tas_single_node_setup_host_dns | Set up DNS on the managed host to resolve URLs of the configured RHTAS services. | bool |  `True`  |
| tas_single_node_tsa_signer_type | Signer type to use for TSA. Valid options are: [file, kms, tink]. | str |  |
| tas_single_node_tsa_kms_key_resource | The Key Management Services (KMS) key for signing timestamp responses. Valid options are: [gcpkms://resource, azurekms://resource, hashivault://resource, awskms://resource]. | str |  |
| tas_single_node_tsa_tink_key_resource | The KMS key for signing timestamp responses for Tink keysets. Valid options are: [gcp-kms://resource, aws-kms://resource, hcvault://]. | str |  |
| tas_single_node_tsa_tink_keyset | The KMS-encrypted keyset for Tink that decrypts the tas_single_node_tsa_tink_key_resource string. | str |  |
| tas_single_node_tsa_tink_hcvault_token | The authentication token for Hashicorp Vault API calls. | str |  |
| tas_single_node_skip_os_install | Whether or not to skip the installation of the required operating system packages. Only use this option when all packages are already installed at the versions released for RHEL 9.2 or later. | bool |  `False`  |
| tas_single_node_meta_issuers | The list of OIDC meta issuers allowed to authenticate Fulcio certificate requests. | list of dicts of 'tas_single_node_meta_issuers' options |  `[]`  |
| tas_single_node_fulcio_trusted_oidc_ca | Trusted OpenID Connect (OIDC) CA certificate for Fulcio, used to validate the identity of the OIDC provider. | str |  |
| tas_single_node_trillian_trusted_ca | Trusted CA certificate for Trillian, enabling secure TLS connections between the Trillian Logserver/Logsigner and the Trillian database. This CA certificate validates the authenticity of the Trillian database, ensuring encrypted and trusted data exchanges. | str |  |
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
| tas_single_node_podman | Configuration options for Podman. | dict of 'tas_single_node_podman' options |  |

#### Options for main > tas_single_node_rekor_redis

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| database_deploy | Whether or not to deploy Redis. | bool | no |  |
| redis | Details on the Redis connection. | dict of 'redis' options | no |  |

#### Options for main > tas_single_node_rekor_redis > redis

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| host | The Redis host. | str | no |  |
| port | The Redis host port number. | int | no |  |
| password | The Redis password. | str | no |  |

#### Options for main > tas_single_node_trillian

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| database_deploy | Whether or not to deploy the database. | bool | no |  |
| mysql | Details on the database connection. | dict of 'mysql' options | no |  |

#### Options for main > tas_single_node_trillian > mysql

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| host | The database host. | str | no |  |
| port | The database host port number. | int | no |  |
| password | The database password. | str | no |  |
| user | The database user. | str | no |  |
| root_password | The root password for the database. | str | no |  |
| database | The database name to connect to. | str | no |  |

#### Options for main > tas_single_node_fulcio

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| certificate | Details on the certificate attributes for Fulcio. | dict of 'certificate' options | no |  |
| tas_single_node_fulcio_private_key | The user-provided private key for Fulcio, used for signing root certificate (only RSA with > 2048 B pkey size or ECC with prime256v1 (==secp256r1) are supported). | str | no |  |
| tas_single_node_fulcio_root_ca | The user-provided root certificate for Fulcio. This field is mutually exclusive with the certificate field. | str | no |  |

#### Options for main > tas_single_node_fulcio > certificate

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| organization_name | The name of the organization. | str | no |  |
| organization_email | The email address of the organization. | str | no |  |
| common_name | The common name (e.g., hostname) for the certificate. | str | no |  |

#### Options for main > tas_single_node_oidc_issuers

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| issuer | A unique name of the OIDC issuer. | str | yes |  |
| url | The OIDC issuer service URL. | str | yes |  |
| client_id | The OIDC client identifier used by the RHTAS service. | str | yes |  |
| type | The type of the OIDC token issuer, for example, 'email'. | str | yes |  |

#### Options for main > tas_single_node_meta_issuers

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| issuer_pattern | A URL template to match multiple OIDC issuers, for example, `'https://oidc.eks.*.amazonaws.com/id/*'`. | str | yes |  |
| client_id | The OIDC client identifier used by the RHTAS service. | str | yes |  |
| type | The type of the OIDC token issuer, for example, 'email'. | str | yes |  |

#### Options for main > tas_single_node_podman

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| policy | Contains the content of a `policy.json` file, which defines security policies for container image sources. Replaces the default policy, allowing you to enforce specific rules for image trust and verification in Podman. | str | no |  |
| registry | A list of registries and their corresponding mirrors. Each item in the list should specify a registry location and a mirror to use for pulling images. | list of dicts of 'registry' options | no |  |

#### Options for main > tas_single_node_podman > registry

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| location | The primary registry location for the image. | str | yes |  |
| mirror | The mirror registry to use for pulling images from the primary registry location. | str | yes |  |

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
