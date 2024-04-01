#!/bin/bash

USB0_ADDR="10.0.0.1"
USB0_RANGE="10.0.0.0"

function uninit_usb()
{
    echo "Stop DHCP server"
    systemctl stop isc-dhcp-server
    echo "OK"

    echo "Delete iptables"
    ip link set usb0 down
    ip addr del $USB0_ADDR/30 dev usb0
    iptables -t nat -D POSTROUTING -s $USB0_RANGE/30 -o mlan0 -j MASQUERADE
    echo "OK"

}

function init_usb()
{
    ip link set usb0 up
    ip addr add $USB0_ADDR/30 dev usb0
    iptables -t nat -A POSTROUTING -s $USB0_RANGE/30 -o mlan0 -j MASQUERADE

    echo 1 > /proc/sys/net/ipv4/ip_forward
	ufw allow from $USB0_RANGE/30 to $USB0_ADDR port 53 proto tcp
    ufw allow from $USB0_RANGE/30 to $USB0_ADDR port 53 proto udp
    ufw allow from $USB0_RANGE/30 to $USB0_ADDR port 67 proto udp
    ufw allow from $USB0_RANGE/30 to $USB0_ADDR port 68 proto udp
    systemctl restart dnsmasq
    systemctl restart isc-dhcp-server

}

function status_usb()
{
    if cat /sys/class/net/usb0/operstate | grep -zqFe "up"
        then
            echo "Connect"
	else 
	    echo "No Connect"
     fi
}


case "$1" in 
    start)
	init_usb
    ;;
    stop)
	uninit_usb
    ;;
	status)
	status_usb
	;;

esac
