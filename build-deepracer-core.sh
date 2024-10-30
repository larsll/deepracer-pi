#!/usr/bin/env bash
set -e

export DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Init ROS
#sudo rosdep init
#sudo rosdep fix-permissions
rosdep update --rosdistro=humble

# Set the environment
source /opt/ros/humble/setup.bash
source /opt/intel/openvino_2022/setupvars.sh

# Change to build directory
cd $DIR/bundle_ws

# Undo checkouts / patches
for pkg_dir in */; 
do
    cd $pkg_dir
    if [ -d .git ]; then
        git reset --hard
    fi
    cd ..
done

rosws update

#######
#
# START - Pull request specific changes
#

# Update packages for PR's
# https://github.com/aws-deepracer/aws-deepracer-inference-pkg/pull/4
cd aws-deepracer-inference-pkg
git fetch origin pull/5/head:tflite
git checkout tflite
cd ..

# https://github.com/aws-deepracer/aws-deepracer-camera-pkg/pull/5
cd aws-deepracer-camera-pkg
git fetch origin pull/5/head:compressed-image
git checkout compressed-image
cd ..

# https://github.com/aws-deepracer/aws-deepracer-interfaces-pkg/pull/4
cd aws-deepracer-interfaces-pkg
git fetch origin pull/4/head:compressed-image
git checkout compressed-image
cd ..

# https://github.com/aws-deepracer/aws-deepracer-sensor-fusion-pkg/pull/4
cd aws-deepracer-sensor-fusion-pkg
git fetch origin pull/4/head:compressed-image
git checkout compressed-image
cd ..

# https://github.com/aws-deepracer/aws-deepracer-model-optimizer-pkg/pull/2
cd aws-deepracer-model-optimizer-pkg
git fetch origin pull/3/head:tflite
git checkout tflite
cd ..

# https://github.com/aws-deepracer/aws-deepracer-i2c-pkg/pull/3
cd aws-deepracer-i2c-pkg
git fetch origin pull/3/head:dummy
git checkout dummy
cd ..

# Resolve the dependanices
rosdep install -i --from-path . --rosdistro humble -y

#
# END - Pull request specific changes
#
#######

#######
#
# START - PI specific patches
#

cd aws-deepracer-i2c-pkg/
git apply $DIR/files/patches/aws-deepracer-i2c-pkg.rpi.patch
cd $DIR/bundle_ws

cd aws-deepracer-servo-pkg/
git apply $DIR/files/patches/aws-deepracer-servo-pkg.rpi.patch
cd $DIR/bundle_ws

cd aws-deepracer-systems-pkg/
git apply $DIR/files/patches/aws-deepracer-systems-pkg.rpi.patch
cd $DIR/bundle_ws

cd aws-deepracer-status-led-pkg/
git apply $DIR/files/patches/aws-deepracer-status-led-pkg.rpi.patch
cd $DIR/bundle_ws

cd aws-deepracer-webserver-pkg/
git apply $DIR/files/patches/aws-deepracer-webserver-pkg.rpi.patch
cd $DIR/bundle_ws

cd aws-deepracer-ctrl-pkg/
git apply $DIR/files/patches/aws-deepracer-ctrl-pkg.rpi.patch
cd $DIR/bundle_ws

cd aws-deepracer-inference-pkg/
git apply $DIR/files/patches/aws-deepracer-inference-pkg.rpi.patch
cd $DIR/bundle_ws

cd aws-deepracer-model-optimizer-pkg/
git apply $DIR/files/patches/aws-deepracer-model-optimizer-pkg.rpi.patch
cd $DIR/bundle_ws

cd aws-deepracer-sensor-fusion-pkg/
git apply $DIR/files/patches/aws-deepracer-sensor-fusion-pkg.rpi.patch
cd $DIR/bundle_ws

cd aws-deepracer-usb-monitor-pkg/
git apply $DIR/files/patches/aws-deepracer-usb-monitor-pkg.rpi.patch
cd $DIR/bundle_ws

cd aws-deepracer-navigation-pkg/
git apply $DIR/files/patches/aws-deepracer-navigation-pkg.rpi.patch
cd $DIR/bundle_ws

cd aws-deepracer-device-info-pkg/
git apply $DIR/files/patches/aws-deepracer-device-info-pkg.rpi.patch
cd $DIR/bundle_ws

#
# END - Patches
#
#######


# Remove previous builds (gives clean build)
rm -rf install build log

# Update deepracer_launcher.py (fix an issue in the file)
cp ../files/deepracer_launcher.py ./aws-deepracer-launcher/deepracer_launcher/launch/deepracer_launcher.py

export PYTHONWARNINGS=ignore:::setuptools.command.install
# Build the core
colcon build --packages-up-to deepracer_launcher rplidar_ros

# Build the add-ons
colcon build --packages-up-to logging_pkg

cd $DIR

set +e
echo "Done!"
