#!/bin/sh
BODY=$1
LEN=$( echo -n ${BODY} | wc -c)
echo -ne "PUT /TariffServer/webresources/Tariff HTTP/1.0\r\nHost:tariffserver.interhost.co.il\r\n\Accept: */*\r\nContent-Type: application/json\r\nauth_token: $2\r\nContent-Length: ${LEN}\r\n\r\n$BODY" | nc -i 3 tariffserver.interhost.co.il 8080
echo "${BODY}" > /tmp/json.tmp
