# Ansible Role Vault

Install vault as docker container

This is as a first step implemented for a simple installation on one host, nevertheless the default storage configuration is `raft` (kind of for extensibility) and waiting for the cluster to become ready before adding configuations is builtin.

There are role variables to

* add auth methods (`vault_auth_methods`)
* add secret engines (`vault_secret_engines`)
* add policies (`vault_policies`)
* add data (`vault_writes`)
* add key-values (`vault_kv_puts`)

All configurations on vault are done by the vault cli with `ansible.builtin.shell` and made idempotent by creating a file named `ansible_done_*` in `vault_home`.

The output of `vault init` is saved as JSON and encrypted with `openssl` with the secret `vault_encrypt_secret`.

## Collection dependencies

The role depends on the collection community.docker.
Note that this also requires installation of the python libraries `docker` and `docker-compose`.

## Role Variables

### `vault_version`: `1.7.3`

the vault version (docker image tag)

### `vault_home`: `/srv/vault`

the home of the vault docker volumes

### `vault_docker_expose_api`: `127.0.0.1:8200:8200`

the docker expose of the vault api

### `vault_docker_expose_cluster`: `127.0.0.1:8201:8201`

the docker expose of the cluster

### `vault_key_shares`: `1`

the value for the `vault init` parameter `-key-shares`

### `vault_key_threshold`: `1`

the value for the `vault init` parameter `-key-threshold`

### `vault_auth_methods`: `[]`

the list of auth methods to be enable by `vault auth enable`

### `vault_secret_engines`: `[]`

the list of secret engines to be enabled by `vault secrets enable`

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

### `vault_policies`: `[]`

the list of policies to be added by `vault policy write`

An item in `vault_policies` has the following parts:

* `name` for the name of the policy
* `hcl` for the policy definition

for example:

```yaml
vault_policies
- name: gitlab
  hcl: |
    path "gitlab/secret*" {
      capabilities = [ "read" ]
    }
```

### `vault_writes`: `[]`

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

### `vault_kv_puts`: `[]`

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

### `vault_show_unseal_keys`: `no`

if the unseal keys are shown

### `vault_show_root_token`: `no`

if the root token is shown

### `vault_encrypt_secret`: `CHANGE_vault_encrypt_secret`

the secret the output of the vault initialization is encoded

ATTENTION: Keep this confidential! This is the root of the secret management in vault.
