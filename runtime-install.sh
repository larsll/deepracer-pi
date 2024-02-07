#/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
export DIR="$(dirname $SCRIPT_DIR)"

mkdir -p $DIR/deps

# From https://medium.com/@nullbyte.in/raspberry-pi-4-ubuntu-20-04-lts-ros2-a-step-by-step-guide-to-installing-the-perfect-setup-57c523f9d790
apt update &&  apt install locales 
locale-gen en_US en_US.UTF-8
update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# First ensure that the Ubuntu Universe repository is enabled.
apt install software-properties-common curl 
add-apt-repository universe
apt -y update && apt -y upgrade

# Now add the ROS 2 GPG key with apt.
# Then add the repository to your sources list.
curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" |  tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Install ROS Core and Development Tools
apt -y update && apt install -y ros-foxy-ros-base python3-argcomplete ros-dev-tools python3-pip libopencv-dev libjsoncpp-dev libhdf5-dev \
     	python3-opencv python3-websocket python3-colcon-common-extensions python3-rosinstall cython3 libuvc0 

# Make directory
mkdir -p /opt/aws/deepracer
apt -m venv --prompt dr /opt/aws/deepracer/.venv
source /opt/aws/deepracer/.venv/bin/activate

# Update Python
pip3 install -U "setuptools<50" pip 
pip3 install gdown

# Tensorflow and dependencies
cd $DIR/deps/
gdown --fuzzy https://drive.google.com/file/d/1rfgF2U2oZJvQSMbGNZl8f5jbWP4fY6UW/view?usp=sharing
pip3 install tensorflow*.whl
pip3 install pyudev \
	"flask<3" \
	flask_cors \
	flask_wtf \
	pam \
	networkx \
	unidecode \
	defusedxml \
	pyserial

# Switch nameserver
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
echo "DNSStubListener=no" |  tee -a /etc/systemd/resolved.conf
systemctl restart systemd-resolved

# Install packages
curl -O https://larsll-build-artifact-share.s3.eu-north-1.amazonaws.com/deepracer-pi/aws-deepracer-core_2.0.383.1%2Bcommunity_arm64.deb
curl -O https://larsll-build-artifact-share.s3.eu-north-1.amazonaws.com/deepracer-pi/aws-deepracer-device-console_2.0.196.0_arm64.deb
curl -O https://larsll-build-artifact-share.s3.eu-north-1.amazonaws.com/deepracer-pi/aws-deepracer-sample-models_2.0.9.0_all.deb
curl -O https://larsll-build-artifact-share.s3.eu-north-1.amazonaws.com/deepracer-pi/aws-deepracer-util_2.0.61.0_arm64.deb
apt install -y ./*.deb

# Get OpenVINO
curl -O https://larsll-build-artifact-share.s3.eu-north-1.amazonaws.com/deepracer-pi/openvino_2021.3_arm64.tgz
cd /
tar xvzf $DIR/deps/openvino_2021.3_arm64.tgz
rm $DIR/deps/openvino_2021.3_arm64.tgz
ln -sf /opt/intel/openvino_2021.3 /opt/intel/openvino_2021
ln -sf /opt/intel/openvino_2021.3 /opt/intel/openvino