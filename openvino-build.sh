#!/usr/bin/env bash

set +e

cd ~/
git clone --depth 1 --branch 2021.3 https://github.com/openvinotoolkit/openvino.git
cd ~/openvino
git submodule update --init --recursive
sh ./install_build_dependencies.sh
cd ~/openvino/inference-engine/ie_bridges/python/

pip3 install -r requirements.txt

export OpenCV_DIR=/aarch64-linux-gnu/cmake/opencv4

cd ~/openvino

mkdir -p build && cd build

cmake -DCMAKE_BUILD_TYPE=Release \
-DCMAKE_INSTALL_PREFIX=/opt/intel/openvino_2021.3 \
-DENABLE_MKL_DNN=OFF \
-DENABLE_CLDNN=OFF \
-DENABLE_GNA=OFF \
-DENABLE_SSE42=OFF \
-DTHREADING=SEQ \
-DENABLE_OPENCV=OFF \
-DNGRAPH_PYTHON_BUILD_ENABLE=ON \
-DNGRAPH_ONNX_IMPORT_ENABLE=ON \
-DENABLE_PYTHON=ON \
-DPYTHON_EXECUTABLE=$(which python3.8) \
-DPYTHON_LIBRARY=/usr/lib/aarch64-linux-gnu/libpython3.8.so \
-DPYTHON_INCLUDE_DIR=/usr/include/python3.8 \
-DCMAKE_CXX_FLAGS=-latomic ..

make -j4 
