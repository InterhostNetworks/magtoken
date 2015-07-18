#!/bin/sh
BODY=$1
LEN=$( echo -n ${BODY} | wc -c)
echo -ne "POST /TariffServer/webresources/authentication/login HTTP/1.0\r\nHost:tariffserver.interhost.co.il\r\n\Accept: */*\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: ${LEN}\r\n\r\n$BODY" | nc -i 3 tariffserver.interhost.co.il 8080
echo "${BODY}" > /tmp/json.tmp
