Lightweight image to run Ultrahook.

If you find way to install even less dependencies, please let me know.

Usage:

```
docker run \
  --network host \
  -e ULTRAHOOK_TARGET_PORT=8080\
  -e ULTRAHOOK_DOMAIN=stripe\
  -e ULTRAHOOK_KEY=XXXXXXXXXXXXX\
  ultrahook
```