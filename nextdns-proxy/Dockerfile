FROM alpine:latest

EXPOSE 53
EXPOSE 53/udp

RUN apk update; apk upgrade &&\
    wget -O /etc/apk/keys/nextdns.pub https://repo.nextdns.io/nextdns.pub &&\ 
    echo https://repo.nextdns.io/apk | tee -a /etc/apk/repositories >/dev/null &&\
    apk update && apk add nextdns bind-tools &&\
    mkdir -p /var/nextdns
COPY run.sh /var/nextdns/run.sh

HEALTHCHECK --interval=60s --timeout=10s --start-period=5s --retries=1 \
    CMD dig +time=20 @127.0.0.1 -p 53 probe-test.dns.nextdns.io && dig +time=20 @127.0.0.1 -p 53 probe-test.dns.nextdns.io

CMD ["/var/nextdns/run.sh"]