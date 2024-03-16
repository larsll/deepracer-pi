#!/usr/bin/env bash
set -e

export DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

options='m:i:'
while getopts $options option
do
    case "$option" in
        i  ) IMG_DIR=$OPTARG;;
        m  ) MODEL_DIR=$OPTARG;;
        \? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
        :  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
        *  ) echo "Unimplemented option: -$option" >&2; exit 1;;
    esac
done

if [ -z "$IMG_DIR" ] || [ -z "$MODEL_DIR" ]; then
    echo "Missing -i or -m" >&2
    exit 1
fi

source /opt/intel/openvino/setupvars.sh
source /opt/ros/humble/setup.bash

if [ -f $DIR/bundle_ws/install/setup.bash ]; then
    echo "Using DeepRacer bundle from $DIR/bundle_ws/install/setup.bash"
    source $DIR/bundle_ws/install/setup.bash
elif [ -f /opt/aws/deepracer/lib/setup.bash ]; then
    echo "Using DeepRacer bundle from /opt/aws/deepracer/lib/setup.bash"
    source /opt/aws/deepracer/lib/setup.bash
fi

cd $DIR/test 
rosdep update --rosdistro=humble -q
colcon build

source $DIR/test/install/setup.bash
ros2 launch $DIR/test/launch/inference_comparison_test.launch image_dir:=$IMG_DIR model_dir:=$MODEL_DIR