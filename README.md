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
| basic | `vault_version` | `latest` | the vault version (docker image tag) |
| basic | `vault_home_path` | `/srv/vault` | the home of the vault docker volumes |
| basic | `vault_config_path` | `"{% if vault_install_method != 'service' %}{{ vault_home_path }}/config{% else %}/etc/vault.d{% endif %}"` |
| basic | `vault_log_level` | `"Info"` | the [vault log level](https://www.vaultproject.io/docs/configuration#log_level) |
| basic | `vault_ui` | `'false'` | if the vault user interface should be activated (`'true'` or `'false'`) |
| basic | `vault_api_port` | `8200` | the vault api port (for [`api_addr`](https://www.vaultproject.io/docs/configuration#api_addr) and [`address`](https://www.vaultproject.io/docs/configuration/listener/tcp#address)) |
| basic | `vault_cluster_port` | `8201` | the vault cluster port (for [`cluster_addr`](https://www.vaultproject.io/docs/configuration#cluster_addr) and [`cluster_address`](https://www.vaultproject.io/docs/configuration/listener/tcp#cluster_address)) |
| basic | `vault_api_addr` | `"http://127.0.0.1:{{ vault_api_port }}"` | the [`api_addr`](https://www.vaultproject.io/docs/configuration#api_addr) |
| basic | `vault_cluster_addr` | `"http://127.0.0.1:{{ vault_cluster_port }}"` | the [`cluster_addr`](https://www.vaultproject.io/docs/configuration#cluster_addr) |
| basic | `vault_listener_bind_address` | `127.0.0.1` | the vault bind address (for [`api_addr`](https://www.vaultproject.io/docs/configuration#api_addr)) |
| basic | `vault_listener_bind_cluster_address` | `127.0.0.1` | the vault cluster bind address (for [`cluster_addr`](https://www.vaultproject.io/docs/configuration#cluster_addr)) |
| basic | `vault_tls_disable` | `'true'` | if TLS should be disabled in the listener stanza ([`tls_disable`](https://www.vaultproject.io/docs/configuration/listener/tcp#tls_disable)) |
| basic | `vault_tls_cert_file` | | the path of the certificate for TLS ([`tls_cert_file`](https://www.vaultproject.io/docs/configuration/listener/tcp#tls_cert_file)) |
| basic | `vault_tls_key_file` | | the path of the private key for the certificate for TLS ([`tls_key_file`](https://www.vaultproject.io/docs/configuration/listener/tcp#tls_key_file)) |
| basic | `vault_disable_mlock` | `'true'` | the value for [`disable_mlock`](https://www.vaultproject.io/docs/configuration#disable_mlock) |
| basic | `vault_storage_raft_path` | `"{% if vault_install_method != 'docker' %}{{ vault_home_path }}{% else %}/vault{% endif %}/file/raft"` | the `path` value for `storage "raft"` |
| basic | `vault_storage_raft_node_id` | `"{{ inventory_hostname }}"` | the `node_id`value for `storage "raft"` |
| Let's Encrypt | `vault_lets_encrypt_chown` | false | if the owner of `/etc/letsencrypt` should be change to `vault:vault` |
| docker | `vault_docker_api_port` | `"{{ vault_api_port }}"` | the port for `vault_docker_expose_api` |
| docker | `vault_docker_cluster_port` | `"{{ vault_cluster_port }}"` | the port for `vault_docker_expose_cluster` |
| docker | `vault_docker_expose_api` | `"127.0.0.1:8200:{{ vault_docker_api_port }}"` | the docker expose of the vault api |
| docker | `vault_docker_expose_cluster` | `"127.0.0.1:8201:{{ vault_docker_cluster_port }}"` | the docker expose of the cluster |
| init | `vault_key_shares` | `1` | the value for the `vault init` parameter `-key-shares` |
| init | `vault_key_threshold` | `1` | the value for the `vault init` parameter `-key-threshold` |
| init | `vault_show_unseal_keys` | `false` | if the unseal keys are shown |
| init | `vault_show_initial_root_token` | `false` | if the root token with no expiration is shown <br /> <span style="color:red">ATTENTION: Keep this confidential! The root tooken with no expiration should be revoked!</span> |
| init | `vault_encrypt_secret` | `CHANGE_vault_encrypt_secret` | the secret the output of the vault initialization is encoded with<br /> <span style="color:red">ATTENTION: Keep this confidential! This is the root of the secret management in vault.</span> |
| init | `vault_create_root_token` | `true` | if a new root token with TTL should be created |
| init | `vault_root_token_ttl` | `10m` | the TTL for the new root token |
| init | `vault_revoke_root_token` | `true` | if the initial root token should be revoked |
| auth | `vault_auth_methods` | `[]` | the list of auth methods to be enable by `vault auth enable` |
| secret | `vault_secret_engines` | `[]` | the list of secret engines to be enabled by `vault secrets enable`, s. [`vault_secret_engines`](#section-vault_secret_engines) |
| policies | `vault_policy_writes` | `[]` | the list of policies to be added by `vault policy write`, s. [`vault_policy_writes`](#section-vault_policy_writes) |
| writes | `vault_writes` | `[]` | the list of data to write vault by `vault write`, s. [`vault_writes`](#section-vault_writes) |
| kv | `vault_kv_puts` | `[]` | the list of key-values to put into vault by `vault kv put`, s. [`vault_kv_puts`](#section-vault_kv_puts) |
| kv | `vault_kv_deletes` | `[]` | the paths to be delete by `vault kv delete`, s. [`vault_kv_deletes`](#section-vault_kv_deletes) |
| approle | `vault_approles` | `[]` | the list of approles to get role_id and secret_id for <br />the result is put with the role name as key into<ul><li>`vault_approle_role_id`</li><li>`vault_approle_secret_id`</li></ul> |
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
