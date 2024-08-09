#FROM irvingpop/refinery:latest AS binary
FROM honeycombio/refinery:2.7.0 AS binary
FROM alpine:latest

RUN apk update && apk add --no-cache bash ca-certificates coreutils tini tshark && update-ca-certificates

COPY --from=binary /ko-app/refinery /ko-app/refinery
COPY connstats.sh /ko-app/connstats.sh
EXPOSE 4317 8080 8081

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/ko-app \
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    KO_DATA_PATH=/var/run/ko

VOLUME /etc/refinery/config.yaml /etc/refinery/rules.yaml

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/ko-app/refinery", "-c", "/etc/refinery/config.yaml", "-r", "/etc/refinery/rules.yaml" ]
