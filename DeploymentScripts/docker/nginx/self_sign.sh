#!/bin/bash
# Store the variables passed from the main script
VARDOMAIN=$1
# Replace the domain in files under $NANOLOCK_HOME
find "$NANOLOCK_HOME" -type f -exec sed -i "s/nanolocksecurity\.nl/$VARDOMAIN/g" {} +

# Steps to Create a Certificate Without Prompts
cd "$NANOLOCK_HOME/nginx"

# Generate private key
sudo openssl genpkey -algorithm RSA -out cert.key -pkeyopt rsa_keygen_bits:2048 >> /nanolock/log.log 2>&1

# Generate certificate signing request (CSR) without prompts
sudo openssl req -new -key cert.key -out cert.csr -config nanolocksecurity.cnf -batch >> /nanolock/log.log 2>&1
sudo openssl x509 -req -in cert.csr -signkey cert.key -out cert.crt -days 3650 -extfile nanolocksecurity.cnf -extensions req_ext >> /nanolock/log.log 2>&1

if [ -d "/tmp/cert" ]; then
    echo "Using client's certificate" >> /nanolock/log.log 2>&1
    mv -v /tmp/cert/cert.crt /nanolock/nginx/cert.crt
    mv -v /tmp/cert/cert.key /nanolock/nginx/cert.key
else
    echo "/tmp/cert does not exist." >> /nanolock/log.log 2>&1
    # Check if there is access to the outside and "/tmp/utilities" does not exist
    if ping -c 1 8.8.8.8 &> /dev/null && [ ! -d "/tmp/utilities" ]; then
        echo "Internet access is available. Using GoDaddy's certificate" >> /nanolock/log.log 2>&1
        mv -v /nanolock/nginx/cert.crt /nanolock/nginx/self_cert.crt
        mv -v /nanolock/nginx/cert.key /nanolock/nginx/self_cert.key
        mv -v /nanolock/nginx/_cert.crt /nanolock/nginx/cert.crt
        mv -v /nanolock/nginx/_cert.key /nanolock/nginx/cert.key
    fi
fi



