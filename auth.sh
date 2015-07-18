#!/bin/sh
LP="username=interhost&password=interhost007008"
./post.sh $LP | grep uuid | cut -d: -f3 | cut -d\" -f2
