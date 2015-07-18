#!/bin/sh
GETMOUNT=`./getmount.sh`
KEY=`cat $GETMOUNT/magtoken.sig`
#CERT=sha1sum cert.crt`
if [ $KEY = '9067e72050b4807024d16ca3d04124506d08de7e34a69bda9eb7f7f5aa990601' ];
then 
        echo 'OK'
fi
