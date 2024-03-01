#!/usr/bin/env bashio
WAIT_PIDS=()
CONFIG_PATH='/share/frpc.ini'
DEFAULT_CONFIG_PATH='/frpc.ini'

function stop_frpc() {
    bashio::log.info "Shutdown frpc client"
    kill -15 "${WAIT_PIDS[@]}"
}

bashio::log.info "Copying configuration."
cp $DEFAULT_CONFIG_PATH $CONFIG_PATH
sed -i "s/server_addr = \"your_server_addr\"/server_addr = \"$(bashio::config 'server_addr')\"/" $CONFIG_PATH
sed -i "s/server_port = 17000/server_port = $(bashio::config 'server_port')/" $CONFIG_PATH
sed -i "s/user = \"admin\"/user = \"$(bashio::config 'user')\"/" $CONFIG_PATH
sed -i "s/meta_token = \"123456789\"/meta_token = \"$(bashio::config 'meta_token')\"/" $CONFIG_PATH
sed -i "s/customDomains = \[\"your_domain\"\]/customDomains = [\"$(bashio::config 'customDomain')\"]/" $CONFIG_PATH
sed -i "s/name = \"your_proxy_name\"/name = \"$(bashio::config 'proxyName')\"/" $CONFIG_PATH


bashio::log.info "Starting frp client"

cat $CONFIG_PATH

cd /usr/src
./frpc -c $CONFIG_PATH & WAIT_PIDS+=($!)

tail -f /share/frpc.log &

trap "stop_frpc" SIGTERM SIGHUP
wait "${WAIT_PIDS[@]}"
