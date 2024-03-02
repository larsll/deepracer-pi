#!/usr/bin/env bash
set -e

export DEBIAN_FRONTEND=noninteractive

# Check we have the privileges we need
if [ `whoami` != root ]; then
    echo "Please run this script as root or using sudo"
    exit 1
fi

export DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

mkdir -p $DIR/dist

systemctl stop unattended-upgrades
apt update -y && apt remove -y unattended-upgrades

# First ensure that the Ubuntu Universe repository is enabled.
apt install -y software-properties-common curl locales
add-apt-repository -y universe
apt update -y && apt upgrade -y

# From https://medium.com/@nullbyte.in/raspberry-pi-4-ubuntu-20-04-lts-ros2-a-step-by-step-guide-to-installing-the-perfect-setup-57c523f9d790
locale-gen en_US en_US.UTF-8
update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# Enable PWM / PCA9685 on I2C 0x40
echo "dtoverlay=i2c-pwm-pca9685a,addr=0x40" | tee -a /boot/firmware/config.txt

# Switch nameserver
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
echo "DNSStubListener=no" |  tee -a /etc/systemd/resolved.conf >/dev/null
systemctl restart systemd-resolved

# Firewall enable
ufw allow "OpenSSH"
ufw enable

# Install other tools / configure network management
apt -y install network-manager wireless-tools net-tools i2c-tools v4l-utils libraspberrypi-bin raspi-config
cp $DIR/files/10-manage-wifi.conf /etc/NetworkManager/conf.d/
systemctl disable systemd-networkd-wait-online

sed -i 's/wifi.powersave = 3/wifi.powersave = 2/' /etc/NetworkManager/conf.d/default-wifi-powersave-on.conf
sed -i 's/renderer: networkd/renderer: NetworkManager/' /etc/netplan/50-cloud-init.yaml
echo -e "\nRestarting the network stack. This might require reconnection. Pi might receive a new IP address."
echo -e "If using Raspberry Pi Camera please run raspi-config and enable legacy camera support.\n"
echo -e "After script has finished, reboot.\n"
systemctl restart NetworkManager
netplan apply
