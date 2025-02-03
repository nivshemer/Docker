#!/bin/bash

export VAULT_ADDR='http://0.0.0.0:8210' >> /nanolock/log.log 2>&1
export VAULT_TOKEN=nanolock-s3cr3t >> /nanolock/log.log 2>&1

vault secrets enable -path=secret kv >> /nanolock/log.log 2>&1

vault kv put secret/postgres/config POSTGRES_PASSWORD="POSTGRES_PW" REPLICATION_PASS="POSTGRES_PW" >> /nanolock/log.log 2>&1

vault kv put secret/grafana/config DATA_SOURCE_NAME="postgresql://nanolocksec:POSTGRES_PW@envvar.nanolocksecurity.nl:5432?sslmode=disable" >> /nanolock/log.log 2>&1


