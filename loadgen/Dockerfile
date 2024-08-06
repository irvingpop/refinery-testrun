FROM ghcr.io/honeycombio/loadgen/loadgen:v0.3.0 AS binary
FROM alpine:latest

RUN apk update && apk add --no-cache bash ca-certificates && update-ca-certificates

COPY --from=binary /ko-app/loadgen /ko-app/loadgen
COPY launcher.sh /ko-app/launcher.sh

# ENTRYPOINT ["loadgen", "-c", "/etc/loadgen/config.yaml"]
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/ko-app \
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    KO_DATA_PATH=/var/run/ko

VOLUME /etc/loadgen/config.yaml
