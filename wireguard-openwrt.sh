#!/bin/sh

# ***************************** OpenWRT VPN *****************************
# * Programmatically switch between WireGuard VPNs for OpenWRT routers. *
# * Tested on TP-Link Archer AX23 v1, OpenWrt 23.05.4, MediaTek MT7621. *
# *************** Questions - https://github.com/alpatiev ***************
# ***********************************************************************

ACTION="$1"
NAME="$2"
shift 2

# ARGS
while [ "$#" -gt 0 ]; do
  case "$1" in
    --private-key) PRIVATE_KEY="$2"; shift 2 ;;
    --address4) ADDRESS4="$2"; shift 2 ;;
    --address6) ADDRESS6="$2"; shift 2 ;;
    --public-key) PUBLIC_KEY="$2"; shift 2 ;;
    --endpoint-host) ENDPOINT_HOST="$2"; shift 2 ;;
    --endpoint-port) ENDPOINT_PORT="$2"; shift 2 ;;
    --dns) DNS="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [ "$ACTION" = "connect" ]; then
  # **CONNECT**
  echo "[?] Connecting to $NAME.."
  
  # >> INTERFACE
  echo "[ ] Setting up interface"
  uci set network."$NAME"='interface'
  uci set network."$NAME".proto='wireguard'
  uci set network."$NAME".private_key="$PRIVATE_KEY"
  uci add_list network."$NAME".addresses="$ADDRESS4"
  uci add_list network."$NAME".addresses="$ADDRESS6"
  
  # >> PEER SETUP
  echo "[ ] Setting up peer config"
  PEER=$(uci add network wireguard_"$NAME")
  uci set network."$PEER".public_key="$PUBLIC_KEY"
  uci set network."$PEER".endpoint_host="$ENDPOINT_HOST"
  uci set network."$PEER".endpoint_port="$ENDPOINT_PORT"
  uci set network."$PEER".persistent_keepalive='25'
  uci add_list network."$PEER".allowed_ips='0.0.0.0/0'
  uci add_list network."$PEER".allowed_ips='::/0'
  uci set network."$PEER".route_allowed_ips='1'
  uci set network."$PEER".interface="$NAME"
  uci commit network
  
  echo "[ ] Reloading.."
  /etc/init.d/network reload

  # >> FIREWALL
  echo "[ ] Firewall setup"
  uci add_list firewall.@zone[1].network="$NAME"
  uci commit firewall
  /etc/init.d/firewall restart
  
  if [ -n "$DNS" ]; then
    echo "nameserver $DNS" > /tmp/resolv.conf.auto
    ln -sf /tmp/resolv.conf.auto /tmp/resolv.conf
    /etc/init.d/dnsmasq restart
  fi

  # >> ENABLE INTERFACE & ROUTE
  ifup "$NAME"
  ip route add default dev "$NAME" metric 10
  
  echo "[+] Success"
elif [ "$ACTION" = "disconnect" ]; then
  # **DISCONNECT**
  echo "Disconnecting $NAME.."

  # >> DELETE ROUTE AND DOWN INTERFACE
  ip route del default dev "$NAME" 2>/dev/null
  ifdown "$NAME"

  # >> DELETING INTERFACE
  uci delete network."$NAME"
  uci delete network.@wireguard_"$NAME"[0]
  uci commit network
  
  echo "[ ] Reloading.."
  /etc/init.d/network reload
  
  echo "[+] Success"
else
  echo "Usage:"
  echo "  $0 connect <name> --private-key ... --IPv4 ... --IPv6 ... --public-key ... --endpoint-host ... --endpoint-port ... --dns ..."
  echo "  $0 disconnect <name>"
  exit 1
fi
