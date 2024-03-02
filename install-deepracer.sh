#!/usr/bin/env bash
set -e

DEBIAN_FRONTEND=noninteractive

# Check we have the privileges we need
if [ $(whoami) != root ]; then
    echo "Please run this script as root or using sudo"
    exit 1
fi

export DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Now add the ROS 2 GPG key with apt.
# Then add the repository to your sources list.
curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list >/dev/null

# Install ROS Core and Development Tools
apt -y update && apt install -y ros-humble-ros-base python3-argcomplete ros-dev-tools python3-pip libopencv-dev libjsoncpp-dev libhdf5-dev \
    python3-opencv python3-websocket python3-venv python3-colcon-common-extensions python3-rosinstall cython3 libuvc0 \
    ros-humble-cv-bridge ros-humble-image-transport ros-humble-compressed-image-transport libboost-dev libboost-thread-dev libboost-regex-dev libboost-filesystem-dev libpugixml1v5
rosdep init && rosdep update --rosdistro=humble

# Update build tools and utilities for Python
pip3 install -U "setuptools<50" pip "cython<3" "wheel==0.42.0" testresources

# Get OpenVINO
mkdir -p $DIR/dist/
cd $DIR/dist/
[ ! -f "$DIR/dist/openvino_2022.3.1_arm64.tgz" ] && curl -O https://larsll-build-artifact-share.s3.eu-north-1.amazonaws.com/deepracer-pi-2204/openvino_2022.3.1_arm64.tgz
cd /
tar xvzf $DIR/dist/openvino_2022.3.1_arm64.tgz
ln -sf /opt/intel/openvino_2022.3.1 /opt/intel/openvino_2022
ln -sf /opt/intel/openvino_2022.3.1 /opt/intel/openvino

# Tensorflow and dependencies
pip3 install -U pyudev \
    "flask<3" \
    flask_cors \
    flask_wtf \
    pam \
    networkx \
    unidecode \
    pyserial \
    "tensorflow" \
    "numpy" \
    "protobuf" \
    "tensorboard" \
    "blinker==1.4" \
    pyclean \
    /opt/intel/openvino_2022.3.1/tools/openvino_dev-2022.3.1-1-py3-none-any.whl \
    /opt/intel/openvino_2022.3.1/tools/openvino-2022.3.1-1-cp310-cp310-manylinux_2_35_aarch64.whl

# Install packages
cp $DIR/files/aws_deepracer-community.list /etc/apt/sources.list.d/aws_deepracer.list
cp $DIR/files/deepracer-larsll.asc /etc/apt/trusted.gpg.d/
apt update -y && apt install -y aws-deepracer-core aws-deepracer-device-console aws-deepracer-util aws-deepracer-sample-models

# Disable deepracer-core until we are ready
systemctl disable deepracer-core
