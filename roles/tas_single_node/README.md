<!--- to update this file, update files in the role's meta/ directory (and/or its README.j2 template) and run "make role-readme" -->
# Ansible Role: redhat.artifact_signer.tas_single_node
Version: 1.3.0+dev.1

Deploy the [RHTAS](https://docs.redhat.com/en/documentation/red_hat_trusted_artifact_signer) service on a single managed node by using the `tas_single_node` role.
 Requires RHEL 9.4 or later.

## Role Arguments
### Required
|Option|Description|Type|Default|
|---|---|---|---|
| tas_single_node_registry_username | The user name logging in to the registry to pull images. | str |  |
| tas_single_node_registry_password | The user's password to log in to the registry. | str |  |
| tas_single_node_base_hostname | The base host name of the managed node. This generates self-signed certificates for the individual HTTPS endpoints. | str |  |

### Optional
|Option|Description|Type|Default|
|---|---|---|---|
| tas_single_node_podman_network | Name of the Podman network for containers to use. | str |  `rhtas`  |
| tas_single_node_rekor_redis | Details on the Redis connection for Rekor. You can set this to a custom Redis instance. | dict of 'tas_single_node_rekor_redis' options |  `{'database_deploy': True, 'redis': {'host': 'rekor-redis-pod', 'port': 6379, 'password': 'password'}}`  |
| tas_single_node_backfill_redis | Configuration options for the backfill redis job. | dict of 'tas_single_node_backfill_redis' options |  `{'enabled': True, 'schedule': '*-*-* 00:00:00'}`  |
| tas_single_node_trillian | Details on the configuration options for Trillian. Includes user provided database config, and trusted Certificate Authority. You can set this to a custom MySQL or MariaDB instance. | dict of 'tas_single_node_trillian' options |  `{'database_deploy': True, 'mysql': {'user': 'mysql', 'root_password': 'rootpassword', 'password': 'password', 'database': 'trillian', 'host': 'trillian-mysql-pod', 'port': 3306}, 'trusted_ca': ''}`  |
| tas_single_node_ingress_certificates | Details on the certificate settings for various services in the ingress layer. Includes user-provided certificates and private keys for fulcio, rekor, TUF, TSA, rekor-search, and cli-server. | dict of 'tas_single_node_ingress_certificates' options |  `{'root': {'ca_certificate': '', 'private_key': ''}, 'fulcio': {'certificate': '', 'private_key': ''}, 'rekor': {'certificate': '', 'private_key': ''}, 'tuf': {'certificate': '', 'private_key': ''}, 'tsa': {'certificate': '', 'private_key': ''}, 'rekor-search': {'certificate': '', 'private_key': ''}, 'cli-server': {'certificate': '', 'private_key': ''}}`  |
| tas_single_node_fulcio | Details on the certificate settings for Fulcio. Includes organizational details, the user-provided private key for signing the root certificate, and the user-provided root certificate itself. **Note**: Updating any of the certificate attributes (such as `organization_name`, `organization_email`, or `common_name`) or the Certificate Authority passphrase (`ca_passphrase`) key will regenerate the Fulcio certificate, which requires a corresponding manual update in the trust root. | dict of 'tas_single_node_fulcio' options |  `{'certificate': {'organization_name': '', 'organization_email': '', 'common_name': ''}, 'private_key': '', 'root_ca': '', 'trusted_ca': '', 'ca_passphrase': 'rhtas', 'ct_log_prefix': 'rhtasansible', 'fulcio_config': {'oidc_issuers': [], 'meta_issuers': [], 'ci_issuer_metadata': []}}`  |
| tas_single_node_rekor | Details on the Rekor server configuration options. Includes Certificate Authority Passphrase, public key retries, public key delay and more. | dict of 'tas_single_node_rekor' options |  |
| tas_single_node_setup_host_dns | Set up DNS on the managed host to resolve URLs of the configured RHTAS services. | bool |  `True`  |
| tas_single_node_ctlog | Configuration and specification of ctlog Custom Configuration as well as custom keys. | dict of 'tas_single_node_ctlog' options |  `{'ca_passphrase': 'rhtas', 'sharding_config': [{'config': None, 'treeid': None, 'prefix': '', 'root_pem_file': '', 'password': '', 'private_key': ''}], 'private_keys': [], 'public_keys': []}`  |
| tas_single_node_tsa | Details on the certificate and configuration options for Timestamp Authority. Includes organizational details, the different signer types such as `file`, `kms`, and `tink`, NTP monitoring configuration and user provided certificate chain + signer private key. | dict of 'tas_single_node_tsa' options |  `{'env': [], 'signer_type': 'file', 'certificate': {'organization_name': '', 'organization_email': '', 'common_name': ''}, 'kms': {'key_resource': ''}, 'tink': {'key_resource': '', 'keyset': '', 'hcvault_token': ''}, 'signer_private_key': '', 'certificate_chain': '', 'ca_passphrase': 'rhtas', 'ntp_config': '', 'trusted_ca': ''}`  |
| tas_single_node_skip_os_install | Whether or not to skip the installation of the required operating system packages. Only use this option when all packages are already installed at the versions released for RHEL 9.4 or later. | bool |  `False`  |
| tas_single_node_fulcio_server_image | Fulcio image | str |  `registry.redhat.io/rhtas/fulcio-rhel9@sha256:67495de82e2fcd2ab4ad0e53442884c392da1aa3f5dd56d9488a1ed5df97f513`  |
| tas_single_node_trillian_log_server_image | Trillian log server image | str |  `registry.redhat.io/rhtas/trillian-logserver-rhel9@sha256:994a860e569f2200211b01f9919de11d14b86c669230184c4997f3d875c79208`  |
| tas_single_node_logsigner_image | Trillian logsigner image | str |  `registry.redhat.io/rhtas/trillian-logsigner-rhel9@sha256:37028258a88bba4dfaadb59fc88b6efe9c119a808e212ad5214d65072abb29d0`  |
| tas_single_node_rekor_image | Rekor image | str |  `registry.redhat.io/rhtas/rekor-server-rhel9@sha256:133ee0153e12e6562cfea1a74914ebdd7ee76ae131ec7ca0c3e674c2848150ae`  |
| tas_single_node_ct_server_image | ctlog image | str |  `registry.redhat.io/rhtas/certificate-transparency-rhel9@sha256:a0c7d71fc8f4cb7530169a6b54dc3a67215c4058a45f84b87bb04fc62e6e8141`  |
| tas_single_node_redis_image | Redis image | str |  `registry.redhat.io/rhtas/trillian-redis-rhel9@sha256:01736bdd96acbc646334a1109409862210e5273394c35fb244f21a143af9f83e`  |
| tas_single_node_trillian_db_image | Trillian database image | str |  `registry.redhat.io/rhtas/trillian-database-rhel9@sha256:909f584804245f8a9e05ecc4d6874c26d56c0d742ba793c1a4357a14f5e67eb0`  |
| tas_single_node_tuf_image | TUF server image | str |  `registry.redhat.io/rhtas/tuf-server-rhel9@sha256:34f5cdc53a908ae2819d85ab18e35b69dc4efc135d747dd1d2e216a99a2dcd1b`  |
| tas_single_node_netcat_image | Netcat image | str |  `registry.redhat.io/openshift4/ose-tools-rhel8@sha256:486b4d2dd0d10c5ef0212714c94334e04fe8a3d36cf619881986201a50f123c7`  |
| tas_single_node_nginx_image | Nginx image | str |  `registry.redhat.io/rhel9/nginx-124@sha256:71fc4492c3a632663c1e17ec9364d87aa7bd459d3c723277b8b94a949b84c9fe`  |
| tas_single_node_tsa_image | Timestamp Authority Image | str |  `registry.redhat.io/rhtas/timestamp-authority-rhel9@sha256:3fba2f8cd09548d2bd2dfff938529952999cb28ff5b7ea42c1c5e722b8eb827f`  |
| tas_single_node_rekor_search_image | Rekor search UI image | str |  `registry.redhat.io/rhtas/rekor-search-ui-rhel9@sha256:8c478fc6122377c6c9df0fddf0ae42b6f6b1648e3c6cf96a0558f366e7921b2b`  |
| tas_single_node_podman | Configuration options for Podman. | dict of 'tas_single_node_podman' options |  |
| tas_single_node_cockpit | Configuration options for Cockpit. | dict of 'tas_single_node_cockpit' options |  `{'enabled': False, 'user': {'create': False, 'username': 'cockpit-user'}}`  |
| tas_single_node_podman_volume_create_extra_args | A dictionary of additional arguments to pass to the `podman volume create` command for each volume. This allows customization of options when creating specific volumes. Each key in the dictionary corresponds to a volume name with hyphens replaced by underscores. | dict of 'tas_single_node_podman_volume_create_extra_args' options |  `{'trillian_mysql': '', 'rekor_redis_storage': '', 'redis_backfill_storage': '', 'rekor_server': '', 'tuf_repository': '', 'tuf_signing_keys': ''}`  |
| tas_single_node_trust_root | Configuration options for the Trust Root. | dict of 'tas_single_node_trust_root' options |  `{'full_archive': ''}`  |
| tas_single_node_backup_restore | Configuration options for the Backup and Restore of Trusted Artifact Signer. | dict of 'tas_single_node_backup_restore' options |  `{'backup': {'enabled': False, 'schedule': '*-*-* 00:00:00', 'force_run': False, 'passphrase': '', 'directory': '/root/tas_backups'}, 'restore': {'enabled': False, 'source': '', 'passphrase': ''}}`  |

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

#### Options for main > tas_single_node_backfill_redis

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| enabled | Enable or disable the backfill redis job. | bool | no |  |
| schedule | Schedule the backfill redis job should follow. | str | no |  |

#### Options for main > tas_single_node_trillian

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| database_deploy | Whether or not to deploy the database. | bool | no |  |
| mysql | Details on the database connection. | dict of 'mysql' options | no |  |
| trusted_ca | Trusted CA certificate for Trillian, enabling secure TLS connections between the Trillian Logserver/Logsigner and the Trillian database. This CA certificate validates the authenticity of the Trillian database, ensuring encrypted and trusted data exchanges. | str | no |  |

#### Options for main > tas_single_node_trillian > mysql

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| host | The database host. | str | no |  |
| port | The database host port number. | int | no |  |
| password | The database password. | str | no |  |
| user | The database user. | str | no |  |
| root_password | The root password for the database. | str | no |  |
| database | The database name to connect to. | str | no |  |

#### Options for main > tas_single_node_ingress_certificates

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| root | Configuration settings for the Root Certificate Authority used to sign the ingress certificates | dict of 'root' options | no |  |
| fulcio | Certificate details for the fulcio service. | dict of 'fulcio' options | no |  |
| rekor | Certificate details for the rekor service. | dict of 'rekor' options | no |  |
| tuf | Certificate details for the TUF service. | dict of 'tuf' options | no |  |
| tsa | Certificate details for the TSA service. | dict of 'tsa' options | no |  |
| rekor-search | Certificate details for the rekor-search service. | dict of 'rekor-search' options | no |  |
| cli-server | Certificate details for the cli-server service. | dict of 'cli-server' options | no |  |

#### Options for main > tas_single_node_ingress_certificates > root

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| ca_certificate | The root certificate used to initialize the Root Certificate Authority (CA). Used for signing and validating ingress certificates. | str | no |  |
| private_key | The private key corresponding to the root certificate. It is used to sign new certificates. | str | no |  |

#### Options for main > tas_single_node_ingress_certificates > fulcio

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| certificate | The user-provided certificate for fulcio. | str | no |  |
| private_key | The user-provided private key for fulcio. | str | no |  |

#### Options for main > tas_single_node_ingress_certificates > rekor

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| certificate | The user-provided certificate for rekor. | str | no |  |
| private_key | The user-provided private key for rekor. | str | no |  |

#### Options for main > tas_single_node_ingress_certificates > tuf

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| certificate | The user-provided certificate for TUF. | str | no |  |
| private_key | The user-provided private key for TUF. | str | no |  |

#### Options for main > tas_single_node_ingress_certificates > tsa

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| certificate | The user-provided certificate for TSA. | str | no |  |
| private_key | The user-provided private key for TSA. | str | no |  |

#### Options for main > tas_single_node_ingress_certificates > rekor-search

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| certificate | The user-provided certificate for rekor-search. | str | no |  |
| private_key | The user-provided private key for rekor-search. | str | no |  |

#### Options for main > tas_single_node_ingress_certificates > cli-server

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| certificate | The user-provided certificate for cli-server. | str | no |  |
| private_key | The user-provided private key for cli-server. | str | no |  |

#### Options for main > tas_single_node_fulcio

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| certificate | Details on the certificate attributes for Fulcio. **Note**: Updating any of these values will regenerate the Fulcio certificate, and a manual update in the trust root is required. | dict of 'certificate' options | no |  |
| private_key | The user-provided private key for Fulcio, used for signing root certificate (only RSA with > 2048 B pkey size or ECC with prime256v1 (==secp256r1) are supported). | str | no |  |
| root_ca | The user-provided root certificate for Fulcio. This field is mutually exclusive with the certificate field. | str | no |  |
| trusted_ca | Trusted OpenID Connect (OIDC) CA certificate for Fulcio, used to validate the identity of the OIDC provider. | str | no |  |
| ca_passphrase | "Passphrase for Certificate Authority. **Note**: Updating the passphrase will regenerate the auto-generated private key and the Fulcio certificate as a consequence, and a manual update in the trust root is required." | str | no |  |
| ct_log_prefix | The Prefix for the Certificate Transparency Log that is accessed by Fulcio. | str | no |  |
| fulcio_config | Fulcio configuration for the OIDC issuers and meta issuers. | dict of 'fulcio_config' options | yes |  |

#### Options for main > tas_single_node_fulcio > certificate

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| organization_name | The name of the organization. | str | no |  |
| organization_email | The email address of the organization. | str | no |  |
| common_name | The common name (e.g., hostname) for the certificate. | str | no |  |

#### Options for main > tas_single_node_fulcio > fulcio_config

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| oidc_issuers | The list of OpenID Connect (OIDC) issuers allowed to authenticate Fulcio certificate requests. | list of dicts of 'oidc_issuers' options | no |  |
| meta_issuers | The list of OIDC meta issuers allowed to authenticate Fulcio certificate requests. | list of dicts of 'meta_issuers' options | no |  |
| ci_issuer_metadata | Additional metadata for ci-provider OIDC issuers. | list of dicts of 'ci_issuer_metadata' options | no |  |

#### Options for main > tas_single_node_fulcio > fulcio_config > oidc_issuers

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| issuer | A unique name of the OIDC issuer. | str | yes |  |
| url | The OIDC issuer service URL. | str | yes |  |
| client_id | The OIDC client identifier used by the RHTAS service. | str | yes |  |
| type | The type of the OIDC token issuer, for example, 'email'. | str | yes |  |
| ci_provider | An optional configuration to map token claims to extensions for CI workflows | str | no |  |

#### Options for main > tas_single_node_fulcio > fulcio_config > meta_issuers

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| issuer_pattern | A URL template to match multiple OIDC issuers, for example, `'https://oidc.eks.*.amazonaws.com/id/*'`. | str | yes |  |
| client_id | The OIDC client identifier used by the RHTAS service. | str | yes |  |
| type | The type of the OIDC token issuer, for example, 'email'. | str | yes |  |
| ci_provider | An optional configuration to map token claims to extensions for CI workflows. | str | no |  |

#### Options for main > tas_single_node_fulcio > fulcio_config > ci_issuer_metadata

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| issuer_name | Name of the issuer. | str | yes |  |
| default_template_values | Defaults contains key-value pairs that can be used for filling the templates from extension_templates. | dict | no |  |
| subject_alternative_name_template | Template for the Subject Alternative Name extension. | str | no |  |
| extension_templates | A mapping between certificate extension and token claim using Go templating syntax. To prevent Ansible from trying to interpolate Go template values, use the "!unsafe" data type. | dict of 'extension_templates' options | no |  |

#### Options for main > tas_single_node_fulcio > fulcio_config > ci_issuer_metadata > extension_templates

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| build_signer_uri | Reference to specific build instructions that are responsible for signing. | str | no |  |
| build_signer_digest | Immutable reference to the specific version of the build instructions that is responsible for signing. | str | no |  |
| runner_environment | Specifies whether the build took place in platform-hosted cloud infrastructure or customer/self-hosted infrastructure. | str | no |  |
| source_repository_uri | Source repository URL that the build was based on. | str | no |  |
| source_repository_digest | Immutable reference to a specific version of the source code that the build was based upon. | str | no |  |
| source_repository_ref | Source Repository Ref that the build run was based upon. | str | no |  |
| source_repository_identifier | Immutable identifier for the source repository the workflow was based upon. | str | no |  |
| source_repository_owner_uri | Source repository owner URL of the owner of the source repository that the build was based on. | str | no |  |
| source_repository_owner_identifier | Immutable identifier for the owner of the source repository that the workflow was based upon. | str | no |  |
| build_config_uri | Build Config URL to the top-level/initiating build instructions. | str | no |  |
| build_config_digest | Immutable reference to the specific version of the top-level/initiating build instructions. | str | no |  |
| build_trigger | Event or action that initiated the build. | str | no |  |
| run_invocation_uri | Run Invocation URL to uniquely identify the build execution. | str | no |  |
| source_repository_visibility_at_signing | Source repository visibility at the time of signing the certificate. | str | no |  |

#### Options for main > tas_single_node_rekor

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| active_signer_type | Active logs signer type can be either file, KMS or tink | str | no |  |
| active_signer_id | ID of the key name containing the active signer key for rekor to use. | str | no |  |
| active_tree_id | Tree Id of active rekor log. | int | no |  |
| kms | Details for KMS configuration of rekor cli-server. | dict of 'kms' options | no |  |
| tink | Details for tink configuration within rekor-server. | dict of 'tink' options | no |  |
| env | Env vars to be specified to access AWS Cloud keys. | list of 'dict' | no |  |
| ca_passphrase | Passphrase used for Certificate Authority cert. | str | no |  |
| public_key_retries | The number of attempts to retrieve the Rekor public key when constructing the trust root. | int | no |  |
| public_key_delay | The number of seconds to wait before retrying the retrieval of the Rekor public key when constructing the trust root. | int | no |  |
| private_keys | List of private keys for use within rekor. | list of dicts of 'private_keys' options | no |  |
| public_keys | List of public keys for use within rekor. | list of dicts of 'public_keys' options | no |  |
| sharding_config | Sharding configuration for rekor | list of dicts of 'sharding_config' options | no |  |

#### Options for main > tas_single_node_rekor > kms

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| kms_resource | KMS resource access | str | no |  |

#### Options for main > tas_single_node_rekor > tink

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| tink_kek_uri | URI for tink resource. | str | no |  |
| tink_keyset_path | Keyset to be unencrypted by tink. | str | no |  |

#### Options for main > tas_single_node_rekor > private_keys

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| id | Custom rekor secret ID. | str | no |  |
| key | Custom Rekor Private key value. | str | no |  |

#### Options for main > tas_single_node_rekor > public_keys

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| id | Custom rekor secret ID. | str | no |  |
| key | Custom Rekor Public key value. | str | no |  |

#### Options for main > tas_single_node_rekor > sharding_config

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| tree_id | Sharding configuration treeID | int | no |  |
| tree_length | Length of rekor tree. | str | no |  |
| signing_config | Signing Configuration or rekor shard. | str | no |  |
| pem_pub_key | ID of custom key provided to rekor. | str | no |  |

#### Options for main > tas_single_node_ctlog

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| ca_passphrase | Passphrase used for Certificate Authority. | str | no |  |
| sharding_config | Configuration for each log in ctlog. | str | no |  |
| private_keys | List of private keys for use within ctlog. | list of dicts of 'private_keys' options | no |  |
| public_keys | List of public keys for use within ctlog. | list of dicts of 'public_keys' options | no |  |

#### Options for main > tas_single_node_ctlog > sharding_config

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| treeid | Trillian Tree Id ctlog use. | int | no |  |
| prefix | ctlog log Prefix. | str | no |  |
| root_pem_file | File path to root Pem file. | str | no |  |
| password | Password for private key used by ctlog. | str | no |  |
| private_key | Name of the private key in the system. | str | no |  |
| override_handler_prefix | Overrides the handler prefix for this log. | str | no |  |
| public_key | Public key used for verification (must be in DER format). | str | no |  |
| reject_expired | Reject certificates that are expired. | bool | no |  |
| reject_unexpired | Reject certificates that are not expired. | bool | no |  |
| not_after_start | Starting timestamp for valid 'NotAfter' dates. | dict of 'not_after_start' options | no |  |
| not_after_limit | Ending timestamp for valid 'NotAfter' dates. | dict of 'not_after_limit' options | no |  |
| accept_only_ca | Only accept certificates with CA extension. | bool | no |  |
| is_mirror | Indicates whether the log is a mirror log. | bool | no |  |
| is_readonly | Indicates whether the log is read-only. | bool | no |  |
| max_merge_delay_sec | Maximum merge delay in seconds. | int | no |  |
| expected_merge_delay_sec | Expected merge delay in seconds. | int | no |  |
| frozen_sth | Signed Tree Head (STH) that freezes the log. | dict | no |  |
| reject_extensions | List of rejected certificate extensions. | str | no |  |
| ctfe_storage_connection_string | Storage connection string for CTFE. | str | no |  |
| extra_data_issuance_chain_storage_backend | Storage backend for extra data issuance chain. | int | no |  |

#### Options for main > tas_single_node_ctlog > sharding_config > not_after_start

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| seconds | Seconds portion of the timestamp. | int | no |  |
| nanos | Nanoseconds portion of the timestamp. | int | no |  |

#### Options for main > tas_single_node_ctlog > sharding_config > not_after_limit

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| seconds | Seconds portion of the timestamp. | int | no |  |
| nanos | Nanoseconds portion of the timestamp. | int | no |  |

#### Options for main > tas_single_node_ctlog > private_keys

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| id | Custom ctlog secret ID. | str | no |  |
| key | Custom ctlog Private key value. | str | no |  |

#### Options for main > tas_single_node_ctlog > public_keys

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| id | Custom ctlog secret ID. | str | no |  |
| key | Custom ctlog Public key value. | str | no |  |

#### Options for main > tas_single_node_tsa

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| signer_type | The signer type for TSA. Options include `file`, `kms`, `tink`. | str | no |  |
| certificate | Details on the certificate attributes for TSA. **Note**: Updating any of the certificate attributes (such as `organization_name`, `organization_email`, or `common_name`) or the Certificate Authority passphrase (`ca_passphrase`) key will regenerate the TSA certificate, which requires a corresponding manual update in the trust root. | dict of 'certificate' options | no |  |
| kms | The Key Management Services (KMS) key for signing timestamp responses. Valid options are: [gcp-kms://resource, aws-kms://resource, hcvault://]. | str | no |  |
| tink | Tink file signer type configuration for TSA. | str | no |  |
| signer_private_key | Signer private key used in conjuction with the certificate chain for signing and verifying. | str | no |  |
| certificate_chain | Certificate chain used in conjuction with the signer private key for signing and verifying. | str | no |  |
| ca_passphrase | Passphrase for Certificate Authority. **Note**: Updating the passphrase will regenerate the auto-generated private key and the TSA certificate as a consequence, and a manual update in the trust root is required." | str | no |  |
| ntp_config | NTP config for time syncing within a unified consensus of vendors such as Google, Amazon, and more. Valid file format and configuration can be found [here](https://github.com/sigstore/timestamp-authority/blob/main/pkg/ntpmonitor/ntpsync.yaml). | str | no |  |
| trusted_ca | Trusted CA certificate for Trusted Timestamp Authority, enabling secure TLS connections. Used to ensure authenticity and trusted data exchange. | str | no |  |
| env | Environment vars to be specified to access AWS Cloud keys when using Tink or KMS | list of 'dict' | no |  |

#### Options for main > tas_single_node_tsa > certificate

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| organization_name | The name of the organization. | str | no |  |
| organization_email | The email of the organization. | str | no |  |
| common_name | The common name (e.g., hostname) for the certificate. | str | no |  |

#### Options for main > tas_single_node_tsa > kms

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| key_resource | Key resource used to access signer private key from AWS/GCP/Azure. | str | no |  |

#### Options for main > tas_single_node_tsa > tink

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| key_resource | The KMS key for signing timestamp responses for Tink keysets. Valid options are: [gcp-kms://resource, aws-kms://resource, hcvault://]. | str | no |  |
| keyset | The KMS-encrypted keyset for Tink that decrypts the tas_single_node_tsa_tink_key_resource string. | str | no |  |
| hcvault_token | The authentication token for Hashicorp Vault API calls. | str | no |  |

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

#### Options for main > tas_single_node_cockpit

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| enabled | Whether or not to install Cockpit. | bool | no |  |
| user | Configuration for the cockpit user. | dict of 'user' options | no |  |

#### Options for main > tas_single_node_cockpit > user

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| create | Whether or not to create the cockpit user. | bool | no |  |
| username | Username for the cockpit user. | str | no |  |
| password | Password for the cockpit user. | str | no |  |

#### Options for main > tas_single_node_podman_volume_create_extra_args

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| trillian_mysql | Additional arguments to pass when creating the "trillian-mysql" volume. | str | no |  |
| rekor_redis_storage | Additional arguments to pass when creating the "rekor-redis-storage" volume. | str | no |  |
| redis_backfill_storage | Additional arguments to pass when creating the "redis-backfill-storage" volume. | str | no |  |
| rekor_server | Additional arguments to pass when creating the "rekor-server" volume. | str | no |  |
| tuf_repository | Additional arguments to pass when creating the "tuf-repository" volume. | str | no |  |
| tuf_signing_keys | Additional arguments to pass when creating the "tuf-signing-keys" volume. | str | no |  |

#### Options for main > tas_single_node_trust_root

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| full_archive | A compressed base64-encoded .tgz file of the trust root. This archive file has a single directory named `tuf-repo/`, containing the contents of the TUF repository, for example `1.root.json`. The default value is an empty string. Using the default value generates the trust root content, unless a trust root already exists. Specifying a `full_archive` string removes any earlier configured trust root content, and starts to use the new specified content. If changing this value back to an empty string after setting the `full_archive` option, then we continue serving the previous value for the trust root content. To reset the trust root content, you must remove all files in the volume associated with the `tuf-repository` pod. | str | no |  |

#### Options for main > tas_single_node_backup_restore

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| backup | Configuration options for the backup. | dict of 'backup' options | no |  |
| restore | Configuration options for the restore. | dict of 'restore' options | no |  |

#### Options for main > tas_single_node_backup_restore > backup

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| enabled | Option to deploy the backup oneshot job and timer. | bool | no |  |
| schedule | The schedule for the backup oneshot job. By default runs daily at midnight. | str | no |  |
| force_run | Forcefully runs a manual backup. | bool | no |  |
| passphrase | The passphrase used to encrypt the compressed backup file. | str | no |  |
| directory | The directory used to store the backups on the remote server. Stored in /root/tas_backups by default. | str | no |  |

#### Options for main > tas_single_node_backup_restore > restore

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| enabled | Configure to restore a full TAS instance. It will always run the restore procedure as long as it is set to true. Should only be set to true on a single Ansible execution and then reverted back to false. | bool | no |  |
| source | The filepath leading the to compressed and encrypted backup file that will be used for the full restore. Needs to be located on the Ansible Control Node. | str | no |  |
| passphrase | The passphrase used to decrypt the compressed backup file. | str | no |  |

## Example Playbook

```
- hosts: rhtas
  vars:
    tas_single_node_registry_username: # TODO: required, type: str
    tas_single_node_registry_password: # TODO: required, type: str
    tas_single_node_base_hostname: # TODO: required, type: str
    
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
