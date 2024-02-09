#!/usr/bin/env bash
set -e

export DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Set the environment
source /opt/ros/foxy/setup.bash 
source /opt/intel/openvino_2021/bin/setupvars.sh

# Change to build directory
cd $DIR/bundle_ws

rosws update

#######
#
# START - Pull request specific changes
# 

# Update packages for PR's
# https://github.com/aws-deepracer/aws-deepracer-inference-pkg/pull/4
cd aws-deepracer-inference-pkg
git fetch origin pull/4/head:compressed-image
git checkout compressed-image
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
git fetch origin pull/2/head:cache-load
git checkout cache-load
cd ..

# Resolve the dependanices
rosdep install -i --from-path . --rosdistro foxy -y

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

#
# END - Patches
#
#######


# Remove previous builds (gives clean build)
rm -rf install build log

# Update deepracer_launcher.py (fix an issue in the file)
cp ../files/deepracer_launcher.py ./aws-deepracer-launcher/deepracer_launcher/launch/deepracer_launcher.py

# Build the core
colcon build --packages-up-to deepracer_launcher rplidar_ros

# Build the add-ons
colcon build --packages-up-to logging_pkg 

cd $DIR

set +e
echo "Done!"
