#!/bin/bash

# which interfaces to use

IN=<in-device>
OUT=<out-device>

# cleanup

function cleanup() {
  pkill -u $UID hostapd
  pkill -u dnsmasq dnsmasq
  service firewalld restart
  nmcli device set ${IN} managed yes
}

trap cleanup EXIT

cleanup

# unmanage wlan device

#nmcli radio wifi off
nmcli device set ${IN} managed no
rfkill unblock wlan

# interface configuration

ip link set ${IN} down
ip addr flush dev ${IN}
ip link set ${IN} up
ip addr add 10.0.0.1/24 dev ${IN}

# firewall configuration

#firewall-cmd --zone=external --change-interface=${OUT}
nmcli connection modify ${OUT} connection.zone external

firewall-cmd -q --zone=internal --change-interface=${IN}
firewall-cmd -q --zone=internal --add-service=dhcp
firewall-cmd -q --zone=internal --add-service=dns
firewall-cmd -q --zone=external --add-masquerade

firewall-cmd -q --direct --add-rule ipv4 nat POSTROUTING 0 -o ${OUT} -j MASQUERADE
firewall-cmd -q --direct --add-rule ipv4 filter FORWARD 0 -i ${IN} -o ${OUT} -j ACCEPT
firewall-cmd -q --direct --add-rule ipv4 filter FORWARD 0 -i ${OUT} -o ${IN} -m state --state RELATED,ESTABLISHED -j ACCEPT
#firewall-cmd --direct --add-passthrough ipv4 -I FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

#iptables --flush
#iptables -t nat -A POSTROUTING -o ${OUT} -j MASQUERADE
#iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
#iptables -A FORWARD -i ${IN} -o ${OUT} -j ACCEPT
#iptables -I FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
#sysctl -w net.ipv4.ip_forward=1

# start daemons

dnsmasq
hostapd /etc/hostapd/hostapd.conf
