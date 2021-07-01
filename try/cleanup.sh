#! /bin/sh

docker kill vault
docker rm vault

sudo rm -rvf /srv/vault/file/raft/*
sudo rm -rvf /srv/vault/config/.vault_*
sudo rm /srv/vault/ansible_done*
