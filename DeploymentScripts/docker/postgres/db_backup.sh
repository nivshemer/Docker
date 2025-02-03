#!/bin/bash

POSTGRES_PASSWORD_VALUE=$(printenv POSTGRES_PASSWORD)

export PGPASSWORD=$POSTGRES_PASSWORD_VALUE; pg_dump -Ft Nivshemersec -U Nivshemersec -h 0.0.0.0 | gzip > /var/lib/postgresql/12/main/archivedir/Nivshemersec-$(date +%d-%m-%y).tar.gz
export PGPASSWORD=$POSTGRES_PASSWORD_VALUE; pg_dump -Ft devicekeystore -U Nivshemersec -h 0.0.0.0 | gzip > /var/lib/postgresql/12/main/archivedir/devicekeystore-$(date +%d-%m-%y).tar.gz
export PGPASSWORD=$POSTGRES_PASSWORD_VALUE; pg_dump -Ft postgres -U Nivshemersec -h 0.0.0.0 | gzip > /var/lib/postgresql/12/main/archivedir/postgres-$(date +%d-%m-%y).tar.gz
export PGPASSWORD=$POSTGRES_PASSWORD_VALUE; pg_dump -Ft notifications -U Nivshemersec -h 0.0.0.0 | gzip > /var/lib/postgresql/12/main/archivedir/notifications-$(date +%d-%m-%y).tar.gz
export PGPASSWORD=$POSTGRES_PASSWORD_VALUE; pg_dump -Ft assets -U Nivshemersec -h 0.0.0.0 | gzip > /var/lib/postgresql/12/main/archivedir/assets-$(date +%d-%m-%y).tar.gz
export PGPASSWORD=$POSTGRES_PASSWORD_VALUE; pg_dump -Ft otd -U Nivshemersec -h 0.0.0.0 | gzip > /var/lib/postgresql/12/main/archivedir/otd-$(date +%d-%m-%y).tar.gz
export PGPASSWORD=$POSTGRES_PASSWORD_VALUE; pg_dump -Ft identity -U Nivshemersec -h 0.0.0.0 | gzip > /var/lib/postgresql/12/main/archivedir/identity-$(date +%d-%m-%y).tar.gz
export PGPASSWORD=$POSTGRES_PASSWORD_VALUE; pg_dump -Ft groupsandpolicies -U Nivshemersec -h 0.0.0.0 | gzip > /var/lib/postgresql/12/main/archivedir/groupsandpolicies-$(date +%d-%m-%y).tar.gz


find /var/lib/postgresql/12/main/archivedir -mtime +14 -type f -delete

