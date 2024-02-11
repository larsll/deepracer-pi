#!/usr/bin/env bash
set -e

# Check we have the privileges we need
if [ `whoami` != root ]; then
    echo "Please run this script as root or using sudo"
    exit 1
fi

export DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Now add the ROS 2 GPG key with apt.
# Then add the repository to your sources list.
curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" |  tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Install ROS Core and Development Tools
apt -y update && apt install -y ros-foxy-ros-base python3-argcomplete ros-dev-tools python3-pip libopencv-dev libjsoncpp-dev libhdf5-dev \
     	python3-opencv python3-websocket python3-venv python3-colcon-common-extensions python3-rosinstall cython3 libuvc0  \
        ros-foxy-cv-bridge ros-foxy-image-transport ros-foxy-compressed-image-transport libboost-dev libboost-thread-dev libboost-regex-dev libboost-filesystem-dev
rosdep init && rosdep update --rosdistro=foxy

# Update build tools and utilities for Python
pip3 install -U "setuptools<50" pip "cython<3" "wheel==0.42.0" testresources && pip3 install gdown

# Tensorflow and dependencies
pip3 install -U pyudev \
    "flask<3" \
    flask_cors \
    flask_wtf \
    pam \
    networkx \
    unidecode \
    defusedxml \
    pyserial \
    "tensorflow" \
	"numpy" \
	"protobuf" \
	"tensorboard" \
    "openvino" \
    "openvino-dev" \
    "empy==3.3.4" \ 
    "lark"

# Install packages
cd $DIR/dist/
[ ! -f "$DIR/dist/aws-deepracer-core_2.0.383.2%2Bcommunity_arm64.deb" ] && curl -O https://larsll-build-artifact-share.s3.eu-north-1.amazonaws.com/deepracer-pi-2204/aws-deepracer-core_2.0.383.2%2Bcommunity_arm64.deb
[ ! -f "$DIR/dist/aws-deepracer-device-console_2.0.196.0_arm64.deb" ] && curl -O https://larsll-build-artifact-share.s3.eu-north-1.amazonaws.com/deepracer-pi-2204/aws-deepracer-device-console_2.0.196.0_arm64.deb
[ ! -f "$DIR/dist/aws-deepracer-sample-models_2.0.9.0_all.deb" ] && curl -O https://larsll-build-artifact-share.s3.eu-north-1.amazonaws.com/deepracer-pi-2204/aws-deepracer-sample-models_2.0.9.0_all.deb
[ ! -f "$DIR/dist/aws-deepracer-util_2.0.61.0_arm64.deb" ] && curl -O https://larsll-build-artifact-share.s3.eu-north-1.amazonaws.com/deepracer-pi-2204/aws-deepracer-util_2.0.61.0_arm64.deb
apt install -y ./*.deb

# Get OpenVINO
[ ! -f "$DIR/dist/openvino_2021.3_arm64.tgz" ] && curl -O https://larsll-build-artifact-share.s3.eu-north-1.amazonaws.com/deepracer-pi/openvino_2021.3_arm64.tgz
cd /
tar xvzf $DIR/dist/openvino_2021.3_arm64.tgz
ln -sf /opt/intel/openvino_2021.3 /opt/intel/openvino_2021
ln -sf /opt/intel/openvino_2021.3 /opt/intel/openvino

# Disable deepracer-core until we are ready
systemctl disable deepracer-core
