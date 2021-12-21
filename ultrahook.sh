#!/usr/bin/env sh
# note: base alpine does not have bash!
# docker run \
#    -e ULTRAHOOK_KEY=XXXXXXXXXXXXX\
#    -e ULTRAHOOK_TARGET=8080\
#    -e ULTRAHOOK_DOMAIN=stripe\
#    --network host \
#    ultrahook

exec ultrahook -k ${ULTRAHOOK_KEY} ${ULTRAHOOK_DOMAIN} ${ULTRAHOOK_TARGET}