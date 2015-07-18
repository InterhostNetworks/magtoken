#!/bin/sh
watch -n 1500 -t /root/magtoken/verify.sh > /dev/null 2>&1 &
PID=$!
echo $PID > /tmp/magtoken.pid
