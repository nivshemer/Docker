#!/bin/bash
# Store the variables passed from the main script
VARDOMAIN=$1
# Replace the domain in files under $Nivshemer_HOME
find "$Nivshemer_HOME" -type f -exec sed -i "s/Nivshemersecurity\.nl/$VARDOMAIN/g" {} +

# Steps to Create a Certificate Without Prompts
cd "$Nivshemer_HOME/nginx"

# Generate private key
sudo openssl genpkey -algorithm RSA -out cert.key -pkeyopt rsa_keygen_bits:2048 >> /Nivshemer/log.log 2>&1

# Generate certificate signing request (CSR) without prompts
sudo openssl req -new -key cert.key -out cert.csr -config Nivshemersecurity.cnf -batch >> /Nivshemer/log.log 2>&1
sudo openssl x509 -req -in cert.csr -signkey cert.key -out cert.crt -days 3650 -extfile Nivshemersecurity.cnf -extensions req_ext >> /Nivshemer/log.log 2>&1

if [ -d "/tmp/cert" ]; then
    echo "Using client's certificate" >> /Nivshemer/log.log 2>&1
    mv -v /tmp/cert/cert.crt /Nivshemer/nginx/cert.crt
    mv -v /tmp/cert/cert.key /Nivshemer/nginx/cert.key
else
    echo "/tmp/cert does not exist." >> /Nivshemer/log.log 2>&1
    # Check if there is access to the outside and "/tmp/utilities" does not exist
    if ping -c 1 8.8.8.8 &> /dev/null && [ ! -d "/tmp/utilities" ]; then
        echo "Internet access is available. Using GoDaddy's certificate" >> /Nivshemer/log.log 2>&1
        mv -v /Nivshemer/nginx/cert.crt /Nivshemer/nginx/self_cert.crt
        mv -v /Nivshemer/nginx/cert.key /Nivshemer/nginx/self_cert.key
        mv -v /Nivshemer/nginx/_cert.crt /Nivshemer/nginx/cert.crt
        mv -v /Nivshemer/nginx/_cert.key /Nivshemer/nginx/cert.key
    fi
fi



