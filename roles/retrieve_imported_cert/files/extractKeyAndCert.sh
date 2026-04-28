#!/bin/sh
#
# This script is used to call a Java program and openssl to extract the private key 
# from a JKS file.  Update the properties below for which one to extract.
#
ALIAS=$1
STOREPASS=$2
KEYPASS=$3
STORE_LOC=$4
IDENTITY_LOC=$5
PKEY_8=${ALIAS}_privatekey.pkcs8
PKEY_64=${ALIAS}_privatekey.b64
CERT_64=${ALIAS}_cert.b64
#CERT_12=${ALIAS}_cert.p12

keytool -alias ${ALIAS} -export -keystore $IDENTITY_LOC -storepass $STOREPASS -keypass $KEYPASS -rfc > $STORE_LOC/${CERT_64}
pwd
java DumpPrivateKey $IDENTITY_LOC ${ALIAS} $STOREPASS $KEYPASS > $STORE_LOC/${PKEY_8}

(echo "-----BEGIN RSA PRIVATE KEY-----" ;
openssl enc -in $STORE_LOC/${PKEY_8} -a;
echo "-----END PRIVATE KEY-----") > $STORE_LOC/${PKEY_64}

#openssl pkcs12 -inkey ${PKEY_64} -in ${CERT_64} -out ${CERT_12} -export
rm $STORE_LOC/${PKEY_8} 
#echo 

