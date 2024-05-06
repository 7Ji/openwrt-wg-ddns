#!/bin/ash
while true; do
    log_network=$(uci show network) 
    # ash does not support <<<
    log_all_wireguard=$(echo "${log_network}" | grep "^network.@wireguard_.\+\[\d\+\]\.\(endpoint_\(host\|port\)\|public_key\)=")
    for interface in $(echo "${log_network}" | sed -n "s/^network\.\(.\+\)\.proto='wireguard'$/\1/p"); do
        log_this_wireguard=$(echo "${log_all_wireguard}" | sed -n "s/^network.@wireguard_${interface}\(\[\d\+\]\..*\)/\1/p")
        for peer in $(echo "${log_this_wireguard}" | cut -d '.' -f 1 | uniq); do # no need to sort
            peer="${peer:1:-1}"
            public_key=
            endpoint_host=
            endpoint_port=
            eval $(echo "${log_this_wireguard}" | sed -n "s/^\[${peer}\]\.\(.*\)/\1/p")
            endpoint_port="${endpoint_port:-51820}"
            echo "=> Interface ${interface} peer ${peer}: public key '${public_key}', endpoint host '${endpoint_host}', endpoint port '${endpoint_port}'"
            ip=$(dig +short "${endpoint_host}" A)
            [ -z "${ip}" ] && ip=$(dig +short "${endpoint_host}" AAAA @1.1.1.1)
            [ -z "${ip}" ] && continue
            echo " -> Resolved '${endpoint_host}' to '${ip}' ..."
            if [ "${ip}" == *:* ]; then
                endpoint="[${ip}]:${endpoint_port}"
            else
                endpoint="${ip}:${endpoint_port}"
            fi
            echo " -> Endpoint updated to '${endpoint}'"
            wg set "${interface}" peer "${public_key}" endpoint "${endpoint}"
        done
    done
    sleep 60
done