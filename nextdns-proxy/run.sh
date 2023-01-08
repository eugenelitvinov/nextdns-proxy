#!/bin/bash

NEXTDNS_MAX_TTL=${NEXTDNS_MAX_TTL:-15}
NEXTDNS_CACHE_SIZE=${NEXTDNS_CACHE_SIZE:-10MB}
NEXTDNS_CONFIG_ID=$NEXTDNS_CONFIG
NEXTDNS_ARGUMENTS="-listen :53 -cache-size=${NEXTDNS_CACHE_SIZE} -max-ttl=${NEXTDNS_MAX_TTL}s"
NEXTDNS_EXTRA_ARGUMENTS=${NEXTDNS_EXTRA_ARGUMENTS:-"-report-client-info -log-queries -use-hosts=false -mdns=disabled -bogus-priv=false"}

echo "Parsing configuration"

while IFS='=' read -r -d '' n v; do
    if [[ "$n" = "NEXTDNS_CONFIG_"* ]]; then
        echo " => Found conditional config: $n => $v"
        NEXTDNS_ARGUMENTS+=" -config $v"
    fi
done < <(env -0)

if [ -n "$NEXTDNS_CONFIG" ]; then
    NEXTDNS_ARGUMENTS+=" -config $NEXTDNS_CONFIG_ID"
    echo " => Found base NextDNS Config: $NEXTDNS_CONFIG_ID"
fi

if [ -n "$NEXTDNS_FORWARDING_DOMAIN" ]; then
    if [ -n "$NEXTDNS_FORWARDING_DNSIP" ]; then
        NEXTDNS_ARGUMENTS+="  -forwarder $NEXTDNS_FORWARDING_DOMAIN=$NEXTDNS_FORWARDING_DNSIP"
    fi
fi

while IFS='=' read -r -d '' n v; do
    if [[ "$n" = "NEXTDNS_FORWARDING_"* ]]; then
        echo " => Found custom forwarding config: $n => $v"
        NEXTDNS_ARGUMENTS+=" -forwarder $v"
    fi
done < <(env -0)

if [ -n "$NEXTDNS_DISCOVERY_DNS" ]; then
    NEXTDNS_ARGUMENTS+=" -discovery-dns $NEXTDNS_DISCOVERY_DNS"
    echo " => Found discovery DNS: $NEXTDNS_DISCOVERY_DNS"
fi

echo "Running nextdns with arguments: $NEXTDNS_ARGUMENTS $NEXTDNS_EXTRA_ARGUMENTS"

/usr/bin/nextdns run $NEXTDNS_ARGUMENTS $NEXTDNS_EXTRA_ARGUMENTS
