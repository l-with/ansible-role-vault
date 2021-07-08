#! /bin/sh

docker kill vault
docker rm vault

sudo rm -rvf /srv/vault/*

export VAULT_ADDR=http://127.0.0.1:9200
