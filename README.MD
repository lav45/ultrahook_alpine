Lightweight image to run Ultrahook.

I had some issue with Ultrahook when deployed on Kubernetes. The long running HTTP streamed request was failing after 5 minutes and there was no retry logic. 
So I have changed the implementation to use `net/http/persistent` but apparently, some bug at Ruby level (or at least it seems so on `net/http/persistent` bug queue page) seems to partially invalidate it's job.
So, I have added, on top of that, some retry logic, that is also useful since Ultrahook secure token expires after a while, and you have to obtain a new one.

At end of the day, this implementation is sort of weak, since evey now and then there are short momements when you lose connectivity with Ultrahook proxy endpoint and you might end up losing notifications.

But it's still better than not having it working at all.

If you have better idea, just let me know.

Usage:

```
docker run \
  --network host \
  -e ULTRAHOOK_TARGET_PORT=http://localhost:8080\
  -e ULTRAHOOK_DOMAIN=stripe\
  -e ULTRAHOOK_KEY=XXXXXXXXXXXXX\
  ultrahook
```