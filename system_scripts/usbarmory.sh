#!/bin/sh
/sbin/iptables -t nat -A POSTROUTING -s 10.0.0.1/32 -o wlp3s0 -j MASQUERADE
echo 1 > /proc/sys/net/ipv4/ip_forward
