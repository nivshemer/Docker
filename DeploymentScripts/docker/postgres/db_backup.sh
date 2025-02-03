#!/bin/bash

POSTGRES_PASSWORD_VALUE=$(printenv POSTGRES_PASSWORD)

export PGPASSWORD=$POSTGRES_PASSWORD_VALUE; pg_dump -Ft nanolocksec -U nanolocksec -h 0.0.0.0 | gzip > /var/lib/postgresql/12/main/archivedir/nanolocksec-$(date +%d-%m-%y).tar.gz
export PGPASSWORD=$POSTGRES_PASSWORD_VALUE; pg_dump -Ft devicekeystore -U nanolocksec -h 0.0.0.0 | gzip > /var/lib/postgresql/12/main/archivedir/devicekeystore-$(date +%d-%m-%y).tar.gz
export PGPASSWORD=$POSTGRES_PASSWORD_VALUE; pg_dump -Ft postgres -U nanolocksec -h 0.0.0.0 | gzip > /var/lib/postgresql/12/main/archivedir/postgres-$(date +%d-%m-%y).tar.gz
export PGPASSWORD=$POSTGRES_PASSWORD_VALUE; pg_dump -Ft notifications -U nanolocksec -h 0.0.0.0 | gzip > /var/lib/postgresql/12/main/archivedir/notifications-$(date +%d-%m-%y).tar.gz
export PGPASSWORD=$POSTGRES_PASSWORD_VALUE; pg_dump -Ft assets -U nanolocksec -h 0.0.0.0 | gzip > /var/lib/postgresql/12/main/archivedir/assets-$(date +%d-%m-%y).tar.gz
export PGPASSWORD=$POSTGRES_PASSWORD_VALUE; pg_dump -Ft otd -U nanolocksec -h 0.0.0.0 | gzip > /var/lib/postgresql/12/main/archivedir/otd-$(date +%d-%m-%y).tar.gz
export PGPASSWORD=$POSTGRES_PASSWORD_VALUE; pg_dump -Ft identity -U nanolocksec -h 0.0.0.0 | gzip > /var/lib/postgresql/12/main/archivedir/identity-$(date +%d-%m-%y).tar.gz
export PGPASSWORD=$POSTGRES_PASSWORD_VALUE; pg_dump -Ft groupsandpolicies -U nanolocksec -h 0.0.0.0 | gzip > /var/lib/postgresql/12/main/archivedir/groupsandpolicies-$(date +%d-%m-%y).tar.gz


find /var/lib/postgresql/12/main/archivedir -mtime +14 -type f -delete

