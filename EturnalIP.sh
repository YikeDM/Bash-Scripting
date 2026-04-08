#!/bin/bash
CONF="/etc/eturnal.yml"
CURRENT_IP=$(cat /etc/eturnal.yml | grep relay_ipv4_addr | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{0-9]\{1,3\}')
ONLINE_IP=$(curl -s https://api.ipify.org)


if [ "$CURRENT_IP" != "$ONLINE_IP" ]; then
  echo "IP Changed from $CURRENT_IP to $ONLINE_IP, updating config..."
  sed -i "s/relay_ipv4_addr:.*/relay_ipv4_addr: $ONLINE_IP/" "$CONF"
  systemctl restart eturnal
  eturnalctl daemon

else
  echo "IP unchanged"
fi
