#!/bin/bash

DOMAIN="balancer"

# Generate a passphrase

export PASSPHRASE=$(head -c 500 /dev/urandom | tr -dc a-z0-9A-Z | head -c 128; echo)

# Certificate details; replace items in angle brackets with your own info

subj="
C=BY
ST=''
O=EPAM
localityName=Minsk
commonName=$DOMAIN
organizationalUnitName=RD
emailAddress=siarhei_kazak@epam.com
"

# Generate the server private key

openssl genrsa -des3 -out $DOMAIN.key -passout env:PASSPHRASE 2048

# Generate the CSR

openssl req -new -batch -subj "$(echo -n "$subj" | tr "\n" "/")" -key $DOMAIN.key -out $DOMAIN.csr -passin env:PASSPHRASE
cp $DOMAIN.key $DOMAIN.key.org

# Shorten the passphrase

openssl rsa -in $DOMAIN.key.org -out $DOMAIN.key -passin env:PASSPHRASE

rm $DOMAIN.key.org

# Generate the cert (good for 10 years)

openssl x509 -req -days 3650 -in $DOMAIN.csr -signkey $DOMAIN.key -out $DOMAIN.crt
unset PASSPHRASE
exit 0