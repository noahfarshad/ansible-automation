#!/bin/bash

BASE_PATH=`dirname "${BASH_SOURCE[0]}"`

openssl enc -base64 -d -in ${BASE_PATH}/passphrase.enc 

