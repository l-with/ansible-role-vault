#! /bin/sh

docker kill vault
docker rm vault

sudo rm -rvf /srv/vault/*
