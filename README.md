# Refinery Test Run

A laboratory for abusing Refinery, particularly good at spinning up arbitrary numbers of loadgens to simulate unique services.

# Using it

First build it
```
docker compose build
```

Next, create a `.env` file to set a Honeycomb API key:
```
export HONEYCOMB_API_KEY="hcaik_mysupersecurekey"
```

Then spin up Refinery
```
docker compose up -d refinery
```

Finally, in 2 terminals:
```
docker compose exec -it refinery connstats.sh
```
```
docker compose up loadgen
```

# Using a custom build of Refinery

`git clone git@github.com:honeycombio/refinery.git` into another place, and change this line:

```
--- a/Dockerfile
+++ b/Dockerfile
@@ -24,4 +24,4 @@ FROM scratch

 COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

-COPY --from=builder /app/refinery /usr/bin/refinery
+COPY --from=builder /app/refinery /ko-app/refinery
```

then, `docker build -t mynamespace/refinery .`
