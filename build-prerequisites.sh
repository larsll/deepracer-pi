#/usr/bin/env bash
set -e

export DEBIAN_FRONTEND=noninteractive

export DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

mkdir -p $DIR/deps $DIR/dist

# From https://medium.com/@nullbyte.in/raspberry-pi-4-ubuntu-20-04-lts-ros2-a-step-by-step-guide-to-installing-the-perfect-setup-57c523f9d790
sudo apt update && sudo apt install locales 
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# First ensure that the Ubuntu Universe repository is enabled.
sudo apt install software-properties-common curl 
sudo add-apt-repository -y universe
sudo apt -y update && sudo apt -y upgrade

# Now add the ROS 2 GPG key with apt.
# Then add the repository to your sources list.
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Install ROS Core and Development Tools
sudo apt -y update && sudo apt install -y python3-venv ros-humble-ros-base libopencv-dev python3-argcomplete ros-dev-tools python3-pip libopencv-dev libjsoncpp-dev libhdf5-dev \
		python3-opencv python3-websocket python3-colcon-common-extensions python3-rosinstall cython3 libuvc0 libboost-all-dev ros-humble-cv-bridge ros-humble-image-transport ros-humble-compressed-image-transport ros-humble-pybind11-vendor ffmpeg ros-humble-test-msgs

# Install venv
python3 -m venv --prompt dr-build .venv
source $DIR/.venv/bin/activate
pip3 install -U "setuptools==58.2.0" pip gdown catkin_pkg "Cython<3"

# Tensorflow and dependencies
cd $DIR/dist/
# gdown --fuzzy https://drive.google.com/file/d/1rfgF2U2oZJvQSMbGNZl8f5jbWP4fY6UW/view?usp=sharing
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

# Compile and Install OpenVINO
./build-openvino.sh

# Install deepracer-scripts
./build-deepracer-core.sh

# Build packages
./build-deepracer-packages.sh
