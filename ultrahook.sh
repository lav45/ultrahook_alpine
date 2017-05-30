#!/usr/bin/env sh
# note: base alpine does not have bash!
# docker run \
#    -e ULTRAHOOK_KEY=XXXXXXXXXXXXX\
#    -e ULTRAHOOK_TARGET_PORT=8080\
#    -e ULTRAHOOK_DOMAIN=stripe\
#    --network host \
#    ultrahook
echo "ULTRAHOOK_TARGET_PORT=${ULTRAHOOK_TARGET_PORT}"
echo "ULTRAHOOK_DOMAIN=${ULTRAHOOK_DOMAIN}"
exec ultrahook -k ${ULTRAHOOK_KEY} $ULTRAHOOK_DOMAIN $ULTRAHOOK_TARGET_PORT