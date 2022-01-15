# Ansible Role Vault

Install vault as docker container

This is as a first step implemented for a simple installation on one host, nevertheless the default storage configuration is `raft` (kind of for extensibility) and waiting for the cluster to become ready before adding configuations is builtin.

There are role variables to

* add auth methods (`vault_auth_methods`)
* add secret engines (`vault_secret_engines`)
* add policies (`vault_policy_writes`)
* add data (`vault_writes`)
* add key-values (`vault_kv_puts`)

All configurations on vault are done by the vault cli with `ansible.builtin.shell` and made idempotent by creating a file named `ansible_done_*` in `vault_home`.

The output of `vault init` is saved as JSON and encrypted with `openssl` with the secret `vault_encrypt_secret`.

## Collection dependencies

The role depends on the collection community.docker.
Note that this also requires installation of the python libraries `docker` and `docker-compose`.

## Role Variables

<!-- markdownlint-disable MD033 -->
| group | variable | default | description |
| --- | --- | --- | --- |
| basic | `vault_version` | `latest` | the vault version (docker image tag) |
| basic | `vault_home` | `/srv/vault` | the home of the vault docker volumes |
| basic | `vault_log_level` | `"Info"` | the [vault log level](https://www.vaultproject.io/docs/configuration#log_level) |
| basic | `vault_ui`| `'false'` | if the vault user interface should be activated (`'true'` or `'false'`) |
| basic | `vault_storage_config` | <code style="display:block">storage "raft" {<br />&nbsp;&nbsp;path&nbsp;&nbsp;&nbsp;&nbsp;= "/vault/file/raft"<br />&nbsp;&nbsp;node_id = "raft_node_1"<br />}<br />cluster_addr = "http://127.0.0.1:8201"</code> | the vault storage config |
| docker | `vault_docker_expose_api` | `127.0.0.1:8200:8200` | the docker expose of the vault api |
| docker | `vault_docker_expose_cluster` | `127.0.0.1:8201:8201` | the docker expose of the cluster |
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
