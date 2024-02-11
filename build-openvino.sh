#!/usr/bin/env bash

set -e

export DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

cd $DIR/deps/
git clone --depth 1 --branch 2022.3 https://github.com/openvinotoolkit/openvino.git
cd $DIR/deps/openvino
git submodule update --init --recursive
sh ./install_build_dependencies.sh
cd $DIR/deps/openvino/inference-engine/ie_bridges/python/

sudo pip3 install -r requirements.txt

export OpenCV_DIR=/usr/lib/aarch64-linux-gnu/cmake/opencv4

cd $DIR/deps/openvino

mkdir -p build && cd build

cmake -DCMAKE_BUILD_TYPE=Release \
-DCMAKE_INSTALL_PREFIX=/opt/intel/openvino_2022.3 \
-DENABLE_MKL_DNN=OFF \
-DENABLE_CLDNN=OFF \
-DENABLE_GNA=OFF \
-DENABLE_SSE42=OFF \
-DTHREADING=SEQ \
-DENABLE_OPENCV=ON \
-DNGRAPH_PYTHON_BUILD_ENABLE=ON \
-DNGRAPH_ONNX_IMPORT_ENABLE=ON \
-DENABLE_PYTHON=ON \
-DPYTHON_EXECUTABLE=$(which python3.10) \
-DPYTHON_LIBRARY=/usr/lib/aarch64-linux-gnu/libpython3.10.so \
-DPYTHON_INCLUDE_DIR=/usr/include/python3.10 \
-DCMAKE_CXX_FLAGS=-latomic ..

make -j4
sudo make install

tar cvzf $DIR/dist/openvino_2021.3.tar.gz /opt/intel/openvino_2021.3

sudo ln -sf /opt/intel/openvino_2022.3 /opt/intel/openvino_2022
sudo ln -sf /opt/intel/openvino_2022.3 /opt/intel/openvino