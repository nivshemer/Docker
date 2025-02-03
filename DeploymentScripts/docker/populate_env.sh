#!/bin/bash

NEWFILENAME=$1
SECRET=$2

export VAULT_ADDR='http://0.0.0.0:8210'
export VAULT_TOKEN=Nivshemer-s3cr3t
#vault kv get secret/postgres/config | tail -2 > $NEWFILENAME
vault kv get $SECRET| tail -2 > $NEWFILENAME


sed -i 's/    /=/g' $NEWFILENAME
sed -i 's/c//g' $NEWFILENAME

