# Ansible Role Vault

Install vault as docker container

This is as a first step implemented for a simple installation on one host, nevertheless the default storage configuration is `raft` (kind of for extensibility) and waiting for the cluster to become ready before adding configuations is builtin.

There are role variables to

* add auth methods (`vault_auth_methods`)
* add secret engines (`vault_secret_engines`)
* add policies (`vault_policies`)

All configurations on vault are done by the vault cli with `ansible.builtin.shell` and made idempotent by creating a file named `ansible_done_*` in `vault_home`.

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

### `vault_auth_methods`: `[]`

the list of auth methods to be enable by `vault auth enable`

### `vault_secret_engines`: `[]`

the list of secret engines to be enabled by `vault secrets enable`

### `vault_policies`: `[]`

the list of policies to be added by vault policy write

A policy has two parts: `name` and `hcl`, for example:

```yaml
- name: gitlab
  hcl: |
    path "gitlab/secret*" {
      capabilities = [ "read" ]
    }
```

### `vault_show_unseal_keys`: `no`

if the unseal keys are shown

### `vault_show_root_token`: `no`

if the root token is shown
