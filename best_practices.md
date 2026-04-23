
<b>Pattern 1: Ensure sensitive data is not exposed in Ansible outputs; use no_log only for commands or tasks that include passphrases or private keys, not for public keys, CSRs, or certificates.</b>

Example code before:
```
- name: Create certificate signing request
  ansible.builtin.command:
    cmd: openssl req -new -key '{{ key_path }}' -passin 'pass:{{ ca_passphrase }}'
  register: csr
- name: Store public key
  ansible.builtin.copy:
    content: "{{ public_key }}"
    dest: "{{ pub_path }}"
  no_log: true
```

Example code after:
```
- name: Create certificate signing request
  ansible.builtin.command:
    cmd: openssl req -new -key '{{ key_path }}' -passin 'pass:{{ ca_passphrase }}'
  register: csr
  no_log: true

- name: Store public key
  ansible.builtin.copy:
    content: "{{ public_key }}"
    dest: "{{ pub_path }}"
  # no_log omitted: public keys/CSRs/certs are not sensitive
```

<details><summary>Examples for relevant past discussions:</summary>

- https://github.com/securesign/artifact-signer-ansible/pull/234#discussion_r2036598462
- https://github.com/securesign/artifact-signer-ansible/pull/234#discussion_r2036599788
- https://github.com/securesign/artifact-signer-ansible/pull/234#discussion_r2036600322
- https://github.com/securesign/artifact-signer-ansible/pull/234#discussion_r2036602863
- https://github.com/securesign/artifact-signer-ansible/pull/234#discussion_r2036609052
</details>


___

<b>Pattern 2: Back up and clean up key material and certificates before regeneration or when passphrase/config changes would invalidate them; never delete keys/certs without first copying them with a timestamp.</b>

Example code before:
```
- name: Regenerate private key
  ansible.builtin.file:
    path: "{{ private_key_path }}"
    state: absent
- name: Generate private key
  ansible.builtin.command: openssl genrsa -out "{{ private_key_path }}" 4096
```

Example code after:
```
- name: Backup existing private key before removal
  ansible.builtin.copy:
    src: "{{ private_key_path }}"
    dest: "{{ private_key_path }}.{{ ansible_date_time.iso8601_basic }}"
    remote_src: true
    mode: '0600'
  when: private_key_exists.stat.exists

- name: Remove old private key
  ansible.builtin.file:
    path: "{{ private_key_path }}"
    state: absent
  when: private_key_exists.stat.exists

- name: Generate private key
  ansible.builtin.command: openssl genrsa -out "{{ private_key_path }}" 4096
```

<details><summary>Examples for relevant past discussions:</summary>

- https://github.com/securesign/artifact-signer-ansible/pull/165#discussion_r1991284649
- https://github.com/securesign/artifact-signer-ansible/pull/195#discussion_r2009981090
- https://github.com/securesign/artifact-signer-ansible/pull/195#discussion_r2010176741
</details>


___

<b>Pattern 3: Enforce early validation and idempotent configuration checks to fail fast, especially for IDs uniqueness and cross-references (e.g., shard public key IDs) before deploying resources.</b>

Example code before:
```
- name: Create ctlog ConfigMap
  ansible.builtin.template:
    src: ctlog-config.j2
    dest: /etc/ctlog/config.yaml
```

Example code after:
```
- name: Assert Rekor custom key IDs are unique
  ansible.builtin.assert:
    that: >
      (((rekor.private_keys|list) + (rekor.public_keys|list)) | map(attribute='id') | list | unique | length)
      == (((rekor.private_keys|list) + (rekor.public_keys|list)) | map(attribute='id') | list | length)
    msg: "Rekor keys must have unique ids."

- name: Assert sharding references existing public key IDs
  ansible.builtin.assert:
    that: "(rekor.public_keys | selectattr('id','equalto', item.pem_pub_key) | list | length) > 0"
  loop: "{{ rekor.sharding_config | default([]) }}"
  loop_control: { loop_var: item }
```

<details><summary>Examples for relevant past discussions:</summary>

- https://github.com/securesign/artifact-signer-ansible/pull/220#discussion_r2028314120
- https://github.com/securesign/artifact-signer-ansible/pull/232#discussion_r2035225675
</details>


___

<b>Pattern 4: Use precise conditions and state tracking to drive certificate/key regeneration only when inputs change (e.g., passphrase, subject attributes, key-certificate mismatch); avoid unnecessary changed_when overrides.</b>

Example code before:
```
- name: Create CSR
  ansible.builtin.command: openssl req -new -key "{{ key }}" -subj "{{ subj }}"
  register: csr
  changed_when: true
```

Example code after:
```
- name: Compute cert attribute hash
  ansible.builtin.set_fact:
    cert_attr_hash: "{{ (cert_attrs | to_json) | hash('sha256') }}"

- name: Read previous attribute hash
  ansible.builtin.slurp:
    src: "{{ config_dir }}/cert_attr_hash"
  register: prev_hash
  failed_when: false

- name: Determine if cert changed
  ansible.builtin.set_fact:
    cert_changed: "{{ (prev_hash.content | default('') | b64decode) != cert_attr_hash }}"

- name: Create CSR only when needed
  ansible.builtin.command: openssl req -new -key "{{ key }}" -subj "{{ subj }}"
  when: cert_changed or key_cert_mismatch
```

<details><summary>Examples for relevant past discussions:</summary>

- https://github.com/securesign/artifact-signer-ansible/pull/165#discussion_r1991284649
- https://github.com/securesign/artifact-signer-ansible/pull/195#discussion_r2009981090
</details>


___

<b>Pattern 5: Validate user-provided certificate/key pairs and fail with a clear message when only one is supplied; allow key-only input to regenerate the matching certificate automatically.</b>

Example code before:
```
- name: Copy provided certificate
  ansible.builtin.copy:
    content: "{{ ingress.certificate }}"
    dest: "{{ cert_path }}"
  when: ingress.certificate != ""
```

Example code after:
```
- name: Fail if certificate provided without private key
  ansible.builtin.fail:
    msg: "Ingress certificate provided but private key is missing; provide both."
  when: ingress.certificate | default('') != '' and ingress.private_key | default('') == ''

- name: Load user-provided key
  ansible.builtin.copy:
    content: "{{ ingress.private_key }}"
    dest: "{{ key_path }}"
  when: ingress.private_key | default('') != ''

- name: Load user-provided certificate
  ansible.builtin.copy:
    content: "{{ ingress.certificate }}"
    dest: "{{ cert_path }}"
  when: ingress.certificate | default('') != '' and ingress.private_key | default('') != ''
```

<details><summary>Examples for relevant past discussions:</summary>

- https://github.com/securesign/artifact-signer-ansible/pull/146#discussion_r1958114361
</details>


___

<b>Pattern 6: Prefer structured variables and consistent schemas (dicts, element types, naming) over ad-hoc strings; reflect these in argument_specs and README to avoid mismatches and enable targeted validation.</b>

Example code before:
```
tas_single_node_podman_volume_create_extra_args: "--opt device=/fast"
rekor:
  sharding_config:
    treeID: 1
    signingConfig: "..."
```

Example code after:
```
tas_single_node_podman_volume_create_extra_args:
  tuf_repository: ""
  tuf_signing_keys: ""
rekor:
  sharding_config:
    - tree_id: 1
      tree_length: "1000"
      signing_config: "..."
      pem_pub_key: "rk-1"
# arguments_spec includes elements, proper casing, and defaults
```

<details><summary>Examples for relevant past discussions:</summary>

- https://github.com/securesign/artifact-signer-ansible/pull/201#discussion_r2015806086
- https://github.com/securesign/artifact-signer-ansible/pull/214#discussion_r2022708093
- https://github.com/securesign/artifact-signer-ansible/pull/220#discussion_r2028317703
- https://github.com/securesign/artifact-signer-ansible/pull/214#discussion_r2022708093
</details>


___
