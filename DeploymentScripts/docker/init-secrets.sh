#!/bin/bash

export VAULT_ADDR='http://0.0.0.0:8210' >> /Nivshemer/log.log 2>&1
export VAULT_TOKEN=Nivshemer-s3cr3t >> /Nivshemer/log.log 2>&1

vault secrets enable -path=secret kv >> /Nivshemer/log.log 2>&1

vault kv put secret/postgres/config POSTGRES_PASSWORD="POSTGRES_PW" REPLICATION_PASS="POSTGRES_PW" >> /Nivshemer/log.log 2>&1

vault kv put secret/grafana/config DATA_SOURCE_NAME="postgresql://Nivshemersec:POSTGRES_PW@envvar.Nivshemersecurity.nl:5432?sslmode=disable" >> /Nivshemer/log.log 2>&1


