#/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
export DIR="$(dirname $SCRIPT_DIR)"

mkdir -p $DIR/deps

# From https://medium.com/@nullbyte.in/raspberry-pi-4-ubuntu-20-04-lts-ros2-a-step-by-step-guide-to-installing-the-perfect-setup-57c523f9d790
sudo apt update && sudo apt install locales 
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# First ensure that the Ubuntu Universe repository is enabled.
sudo apt install software-properties-common curl 
sudo add-apt-repository universe
sudo apt -y update && apt -y upgrade

# Now add the ROS 2 GPG key with apt.
# Then add the repository to your sources list.
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Install ROS Core and Development Tools
sudo apt -y update && apt install -y ros-foxy-ros-base python3-argcomplete ros-dev-tools python3-pip libopencv-dev libjsoncpp-dev libhdf5-dev \
		python3-opencv python3-websocket python3-colcon-common-extensions python3-rosinstall cython3 libuvc0 

# Install venv
apt -m venv --prompt dr-build .venv
source .venv/bin/activate
pip3 install -U "setuptools<50" pip gdown

# Tensorflow and dependencies
cd $DIR/deps/
pip3 install -U "numpy<1.19"
gdown --fuzzy https://drive.google.com/file/d/1rfgF2U2oZJvQSMbGNZl8f5jbWP4fY6UW/view?usp=sharing
pip3 install tensorflow*.whl

# Compile and Install OpenVINO
source build-openvino.sh
sudo mkdir -p /opt/intel
cd $DIR/deps/openvino/build/ && sudo make install
sudo ln -sf /opt/intel/openvino_2021.3 /opt/intel/openvino_2021
sudo ln -sf /opt/intel/openvino_2021.3 /opt/intel/openvino

# Init ROS
sudo rosdep init
sudo rosdep fix-permissions
rosdep update --include-eol-distros

# Install deepracer-scripts
cd $DIR/deps/
git clone https://github.com/davidfsmith/deepracer-scripts
cd deepracer-scripts
./dev-stack-build.sh
