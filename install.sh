#/usr/bin/env bash

# From https://medium.com/@nullbyte.in/raspberry-pi-4-ubuntu-20-04-lts-ros2-a-step-by-step-guide-to-installing-the-perfect-setup-57c523f9d790
sudo apt update && sudo apt install locales --no-install-recommends
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# First ensure that the Ubuntu Universe repository is enabled.
sudo apt install software-properties-common curl --no-install-recommends
sudo add-apt-repository universe

# Now add the ROS 2 GPG key with apt.
sudo apt update 
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

# Then add the repository to your sources list.
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Install ROS2 Packages
sudo apt update && sudo apt -y upgrade

# Install ROS Desktop and Development Tools
sudo apt install -y ros-foxy-desktop python3-argcomplete ros-dev-tools python3-pip --no-install-recommends

# Update Python
sudo pip3 install -U setuptools 

# Other dependencies
sudo apt install libuvc0

# Tensorflow and dependencies
sudo pip3 install -U tensorflow
