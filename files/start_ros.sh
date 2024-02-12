#!/usr/bin/env bash

#################################################################################
#   Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.          #
#                                                                               #
#   Licensed under the Apache License, Version 2.0 (the "License").             #
#   You may not use this file except in compliance with the License.            #
#   You may obtain a copy of the License at                                     #
#                                                                               #
#       http://www.apache.org/licenses/LICENSE-2.0                              #
#                                                                               #
#   Unless required by applicable law or agreed to in writing, software         #
#   distributed under the License is distributed on an "AS IS" BASIS,           #
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    #
#   See the License for the specific language governing permissions and         #
#   limitations under the License.                                              #
#################################################################################

source /opt/aws/deepracer/lib/setup.bash
source /opt/intel/openvino_2022/setupvars.sh
export INTEL_CVSDK_DIR=/opt/intel/openvino_2022

MYRIAD=$(lsusb | grep "Intel Movidius MyriadX")
if [ -n "${MYRIAD}" ]; then
    INFERENCE_ENGINE="MYRIAD"
else
    INFERENCE_ENGINE="CPU"
fi

ros2 launch deepracer_launcher deepracer_launcher.py inference_engine:=${INFERENCE_ENGINE}
