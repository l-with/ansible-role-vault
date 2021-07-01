#! /bin/sh

docker kill vault
docker rm vault

sudo rm -rvf /srv/vault/file/raft/*
sudo rm -rvf /srv/vault/config/.vault_*
sudo rm -rvf /srv/vault/policies/*
sudo rm -rvf /srv/vault/config/policies/*
sudo rm -v /srv/vault/ansible_done*
