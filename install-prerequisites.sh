#!/usr/bin/env bash
set -e

# Check we have the privileges we need
if [ `whoami` != root ]; then
    echo "Please run this script as root or using sudo"
    exit 1
fi

export DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

mkdir -p $DIR/dist

# From https://medium.com/@nullbyte.in/raspberry-pi-4-ubuntu-20-04-lts-ros2-a-step-by-step-guide-to-installing-the-perfect-setup-57c523f9d790
apt update &&  apt install locales 
locale-gen en_US en_US.UTF-8
update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# First ensure that the Ubuntu Universe repository is enabled.
apt install software-properties-common curl 
add-apt-repository universe
apt -y update && apt -y upgrade

# Enable PWM / PCA9685 on I2C 0x40
echo "dtoverlay=i2c-pwm-pca9685a,addr=0x40" | tee -a /boot/firmware/usercfg.txt

# Switch nameserver
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
echo "DNSStubListener=no" |  tee -a /etc/systemd/resolved.conf >/dev/null
systemctl restart systemd-resolved

# Firewall enable
ufw allow "OpenSSH"
ufw enable

# Install other tools / configure network management
apt -y install network-manager wireless-tools net-tools i2c-tools libraspberrypi-bin
copy $DIR/files/10-manage-wifi.conf /etc/NetworkManager/conf.d/
sed -i 's/wifi.powersave = 3/wifi.powersave = 2/' /etc/NetworkManager/conf.d/default-wifi-powersave-on.conf
sed -i 's/renderer: networkd/renderer: NetworkManager/' /etc/netplan/50-cloud-init.yaml
systemctl restart network-manager
netplan apply
