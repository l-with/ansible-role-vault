# Ansible Role Vault

Install vault as docker container

This is as a first step implemented for a simple installation on one host, nevertheless the default storage configuration is `raft` (kind of for extensibility) and waiting for the cluster to become ready before adding configuations is builtin.

The output of `vault init` is saved as JSON and encrypted with `openssl` with the secret `vault_encrypt_secret`.

## Configurations

There are role variables to

* add auth methods (`vault_auth_methods`)
* add secret engines (`vault_secret_engines`)
* add policies (`vault_policy_writes`)
* add data (`vault_writes`)
* add key-values (`vault_kv_puts`)

All configurations on vault are done by the vault cli with `ansible.builtin.shell` and made idempotent by creating a file named `ansible_done_*` in `vault_home_path`.

## Collection dependencies

The role depends on the collection community.docker.
Note that this also requires installation of the python libraries `docker` and `docker-compose`.

## Role Variables

<!-- markdownlint-disable MD033 -->
| group | variable | default | description |
| --- | --- | --- | --- |
| basic | `vault_install_method` | `'docker'` | the install method, supported methods are `'docker'`, `'service'` and `'binary'` |
| basic | `vault_version` | `latest` | the vault version (docker image tag) |
| basic | `vault_home_path` | `/srv/vault` | the home of the vault specific files and folders |
| basic | `vault_config_path` | `"{% if vault_install_method != 'service' %}{{ vault_home_path }}/config{% else %}/etc/vault.d{% endif %}"` |
| basic | `vault_log_level` | `"Info"` | the [vault log level](https://www.vaultproject.io/docs/configuration#log_level) |
| basic | `vault_ui` | `'false'` | if the vault user interface should be activated (`'true'` or `'false'`) |
| basic | `vault_api_port` | `8200` | the vault api port (for [`api_addr`](https://www.vaultproject.io/docs/configuration#api_addr) and [`address`](https://www.vaultproject.io/docs/configuration/listener/tcp#address)) |
| basic | `vault_cluster_port` | `8201` | the vault cluster port (for [`cluster_addr`](https://www.vaultproject.io/docs/configuration#cluster_addr) and [`cluster_address`](https://www.vaultproject.io/docs/configuration/listener/tcp#cluster_address)) |
| basic | `vault_api_addr` | `"http://127.0.0.1:{{ vault_api_port }}"` | the [`api_addr`](https://www.vaultproject.io/docs/configuration#api_addr) |
| basic | `vault_internal_api_addr` | `"{{ vault_api_addr }}"` | the internal adress of the vault api (possible served by a reverse proxy) used for init, unseal and configuration |
| basic | `vault_cluster_addr` | `"http://127.0.0.1:{{ vault_cluster_port }}"` | the [`cluster_addr`](https://www.vaultproject.io/docs/configuration#cluster_addr) |
| basic | `vault_disable_mlock` | `'true'` | the value for [`disable_mlock`](https://www.vaultproject.io/docs/configuration#disable_mlock) |
| tls | `vault_tls_disable` | `'true'` | if TLS should be disabled in the listener stanza ([`tls_disable`](https://www.vaultproject.io/docs/configuration/listener/tcp#tls_disable)) |
| tls | `vault_tls_cert_file` | `"{{ vault_storage_raft_leader_client_cert_file }}"` | the path of the certificate for TLS ([`tls_cert_file`](https://www.vaultproject.io/docs/configuration/listener/tcp#tls_cert_file)) |
| tls | `vault_tls_key_file` | `"{{ vault_storage_raft_leader_client_key_file }}"` | the path of the private key for the certificate for TLS ([`tls_key_file`](https://www.vaultproject.io/docs/configuration/listener/tcp#tls_key_file)) |
| tls | `vault_tls_client_ca` | `false` |
| tls | `vault_tls_client_ca_file` | `"{{ vault_storage_raft_leader_ca_cert_file }}"` | the [`tls_client_ca_file`](https://www.vaultproject.io/docs/configuration/listener/tcp#tls_client_ca_file) |
| raft | `vault_storage_raft_path` | `"{% if vault_install_method != 'docker' %}{{ vault_home_path }}{% else %}/vault{% endif %}/file/raft"` | the `path` value for `storage "raft"` |
| raft | `vault_storage_raft_node_id` | `"{{ inventory_hostname }}"` | the `node_id`value for `storage "raft"` |
| raft | `vault_storage_raft_leader_tls_servername` | | the [`leader_tls_servername`](https://www.vaultproject.io/docs/configuration/storage/raft#leader_tls_servername) |
| raft | `vault_storage_raft_leader_ca_cert_file` |  `"{{ vault_home_path }}/ssl/ca.crt"` | the [`leader_ca_cert_file`](https://www.vaultproject.io/docs/configuration/storage/raft#leader_ca_cert_file) |
| raft | `vault_storage_raft_leader_client_cert_file` | `"{{ vault_home_path }}/ssl/tls-chain.crt"` | the [`leader_client_cert_file`](https://www.vaultproject.io/docs/configuration/storage/raft#leader_client_cert_file) |
| raft | `vault_storage_raft_leader_client_key_file` | `"{{ vault_home_path }}/ssl/tls.key"` | the [`leader_client_key_file`](https://www.vaultproject.io/docs/configuration/storage/raft#leader_client_key_file) |
| raft | `vault_storage_raft_cluster_members` | `[]`| the list of cluster members for the [`retry_join-stanza`](https://www.vaultproject.io/docs/configuration/storage/raft#retry_join-stanza)s |
| raft | `vault_storage_raft_cluster_member_this` | "{{ [hostvars[inventory_hostname].ansible_fqdn] }}" | the actual instance to be excluded for the [`retry_join-stanza`](https://www.vaultproject.io/docs/configuration/storage/raft#retry_join-stanza)s |
| Let's Encrypt | `vault_lets_encrypt_chown` | false | if the owner of `/etc/letsencrypt` should be change to `vault:vault` |
| docker | `vault_docker_network_mode` | `default` |the value for the parameter `network_mode` of [community.docker.docker_container](https://docs.ansible.com/ansible/latest/collections/community/docker/docker_container_module.html) |
| docker | `vault_docker_api_port` | `"{{ vault_api_port }}"` | the port for `vault_docker_expose_api` |
| docker | `vault_docker_cluster_port` | `"{{ vault_cluster_port }}"` | the port for `vault_docker_expose_cluster` |
| docker | `vault_docker_expose_api` | `"127.0.0.1:8200:{{ vault_docker_api_port }}"` | the docker expose of the vault api |
| docker | `vault_docker_expose_cluster` | `"127.0.0.1:8201:{{ vault_docker_cluster_port }}"` | the docker expose of the cluster |
| HA | `vault_ha_wait_retries` | `30` | the number of retries for waiting vault to response status with leader information |
| HA | `vault_ha_wait_delay` | `5` | the delay between the retries for waiting vault to response status with leader information |
| service, binary | `vault_service_wait_retries` | `10` | the number of retries for waiting the service to become active |
| service, binary | `vault_service_wait_delay` | 2 | the delay between the retries for waiting the service to become active |
| binary | `vault_binary_archive_src` | | the source for the binary archive, for instance `https://releases.hashicorp.com/vault/1.9.3/vault_1.9.3_linux_amd64.zip` |
| init | `vault_key_shares` | `1` | the value for the `vault init` parameter `-key-shares` |
| init | `vault_key_threshold` | `1` | the value for the `vault init` parameter `-key-threshold` |
| init | `vault_encrypt_secret` | `CHANGE_vault_encrypt_secret` | the secret the output of the vault initialization is encoded with<br /> <span style="color:red">ATTENTION: Keep this confidential! This is the root of the secret management in vault.</span> |
| init | `vault_create_root_token` | `true` | if a new root token with TTL should be created |
| init | `vault_root_token_ttl` | `10m` | the TTL for the new root token |
| init | `vault_revoke_root_token` | `true` | if the initial root token should be revoked |
| debug | `vault_show_unseal_keys` | `false` | if the unseal keys are shown |
| debug | `vault_show_initial_root_token` | `false` | if the root token with no expiration is shown <br /> <span style="color:red">ATTENTION: Keep this confidential! The root tooken with no expiration should be revoked!</span> |
| debug | `vault_show_root_token` | `false` | if the root token with TTL is shown <br /> <span style="color:red">ATTENTION: Keep this confidential! The root token can be used with th TTL.</span> |
| auth | `vault_auth_methods` | `[]` | the list of auth methods to be enable by `vault auth enable` |
| secret | `vault_secret_engines` | `[]` | the list of secret engines to be enabled by `vault secrets enable`, s. [`vault_secret_engines`](#section-vault_secret_engines) |
| policies | `vault_policy_writes` | `[]` | the list of policies to be added by `vault policy write`, s. [`vault_policy_writes`](#section-vault_policy_writes) |
| writes | `vault_writes` | `[]` | the list of data to write vault by `vault write`, s. [`vault_writes`](#section-vault_writes) |
| kv | `vault_kv_puts` | `[]` | the list of key-values to put into vault by `vault kv put`, s. [`vault_kv_puts`](#section-vault_kv_puts) |
| kv | `vault_kv_deletes` | `[]` | the paths to be delete by `vault kv delete`, s. [`vault_kv_deletes`](#section-vault_kv_deletes) |
| approle | `vault_approles` | `[]` | the list of approles to get role_id and secret_id for <br />the result is put with the role name as key into<ul><li>`vault_approle_role_id`</li><li>`vault_approle_secret_id`</li></ul> |
| listener | `vault_listeners` | `[]` | the list of [`listener`](https://www.vaultproject.io/docs/configuration/listener/tcp)s as list of dicts `vault_listener`|

```yaml
  - address:             vault.example.com:8200
    cluster_address:     vault.example.com:8201
    tls_disable:         'false'
    tls_cert_file:       /srv/vault/ssl/ca.crt
    tls_key_file:        /srv/vault/ssl/tls-chain.crt
    tls_client_ca_file:  /srv/vault/ssl/tls.key
```

| dict | element | default | description |
| --- | --- | --- | --- |
| `vault_listener` | `address` | | the [`address`](https://www.vaultproject.io/docs/configuration/listener/tcp#address) for the listener |
| `vault_listener` | `cluster_address` | | the [`cluster_address`](https://www.vaultproject.io/docs/configuration/listener/tcp#cluster_address) for the listener |
| `vault_listener` | `tls_disable` | `'false'` | the value for [`tls_disable`](https://www.vaultproject.io/docs/configuration/listener/tcp#tls_disable) for the listener |
| `vault_listener` | `tls_cert_file` | `"{{ vault_tls_cert_file }}"` | the [`tls_cert_file`](https://www.vaultproject.io/docs/configuration/listener/tcp#tls_cert_file) for the listener |
| `vault_listener` | `tls_key_file` | `"{{ vault_tls_key_file }}"` | the [`tls_key_file`](https://www.vaultproject.io/docs/configuration/listener/tcp#tls_key_file) for the listener |
| `vault_listener` | `tls_client_ca_file` | `"{{ vault_tls_client_ca_file }}"` | the [`tls_client_ca_file`](https://www.vaultproject.io/docs/configuration/listener/tcp#tls_client_ca_file) for the listener |
<!-- markdownlint-enable MD033 -->

## Output Variables

| group | variable | description |
| --- | --- | --- |
| init | `vault_root_token` | the created root token with TTL |

<!-- markdownlint-disable MD033 -->
### <a name="section-vault_secret_engines">`vault_secret_engines`</a>
<!-- markdownlint-enable MD033 -->

An item in `vault_secret_engines` has the following parts:

* `engine` for the name of the engine
* `options` for the options for the engine, the default is `{}`

for example:

```yaml
vault_secret_engines:
  - engine: ssh
  - engine: kv
    options:
      version: 1
```

<!-- markdownlint-disable MD033 -->
### <a name="section-vault_policy_writes">`vault_policy_writes`</a>
<!-- markdownlint-enable MD033 -->

the list of policies to be added by `vault policy write`

An item in `vault_policy_writes` has the following parts:

* `name` for the name of the policy
* `hcl` for the policy definition

for example:

```yaml
vault_policy_writes
- name: gitlab
  hcl: |
    path "gitlab/secret*" {
      capabilities = [ "read" ]
    }
```

<!-- markdownlint-disable MD033 -->
### <a name="section-vault_writes">`vault_writes`</a>
<!-- markdownlint-enable MD033 -->

the list of data to write vault by `vault write`

An item in `vault_writes` has the following parts:

* `path` for the path
* `force` use the `-force` option, the default is `no`
* `kv` for the key-values

for example:

```yaml
vault_writes:
  - path: auth/jwt/config
    kv:
      jwks_url: https://gitlab.with42.de/-/jwks
      bound_issuer: gitlab.with42.de
```

<!-- markdownlint-disable MD033 -->
### <a name="section-vault_kv_puts">`vault_kv_puts`</a>
<!-- markdownlint-enable MD033 -->

the list of key-values to put into vault by `vault kv put`

An item in `vault_kv_puts` has the following parts:

* `path` for the path
* `cas` the value for the `-cas` option, this part is optional
* `kv` for the key-values

for example:

```yaml
vault_kv_puts:
  - path: secret/cred
    kv:
      pass: secret
      user: user
  - path: secret/config
    cas: 0
    kv:
      security: high
```

The idempotence of `vault_kv_puts` is restricted to the `path`.
If you need to put new key-values to a path, run your playbook play two times with different assignments to `vault_kv_deletes` and `vault_kv_puts`:

* first delete the path with `vault_kv_deletes`
* second put the new key-values to the path with `vault_kv_puts`

<!-- markdownlint-disable MD033 -->
### <a name="section-vault_kv_deletes">`vault_kv_deletes`</a>
<!-- markdownlint-enable MD033 -->

the paths to be delete by `vault kv delete`

An item in `vault_kv_deletes` has the following parts:

* `path` for the path
* `versions` the value for the `-versions` option, this part is optional

Deleting a key-value path in vault is destructive.
The variable `vault_kv_deletes` should only be used for undos.

The deleting of the key-value paths in `vault_kv_deletes` is done before putting the key-values in `vault_kv_puts` to vault.

Using the same path in `vault_kv_deletes` and `vault_kv_puts` is not idempotent.
This is because using `vault_kv_deletes` with a path, destroys the idempotence for `vault_kv_puts` with the same path and vice versa.
