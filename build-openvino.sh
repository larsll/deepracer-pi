#!/usr/bin/env bash

set -e

export DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

cd $DIR/deps/
git clone --depth 1 --branch 2022.3.1 https://github.com/openvinotoolkit/openvino.git
cd $DIR/deps/openvino
git submodule update --init --recursive
sudo ./install_build_dependencies.sh

pip3 install -r ./src/bindings/python/wheel/requirements-dev.txt

mkdir -p build && cd build

cmake -DCMAKE_BUILD_TYPE=Release \
-DOpenCV_DIR=/usr/lib/aarch64-linux-gnu/cmake/opencv4 \
-DCMAKE_INSTALL_PREFIX=/opt/intel/openvino_2022.3.1 \
-DENABLE_MKL_DNN=OFF \
-DENABLE_CLDNN=OFF \
-DENABLE_GNA=OFF \
-DENABLE_SSE42=OFF \
-DTHREADING=SEQ \
-DENABLE_OPENCV=ON \
-DNGRAPH_PYTHON_BUILD_ENABLE=OFF \
-DNGRAPH_ONNX_IMPORT_ENABLE=OFF \
-DENABLE_PYTHON=OFF \
-DPYTHON_EXECUTABLE=$(which python3.10) \
-DPYTHON_LIBRARY=/usr/lib/aarch64-linux-gnu/libpython3.10.so \
-DPYTHON_INCLUDE_DIR=/usr/include/python3.10 \
-DCMAKE_CXX_FLAGS=-latomic ..

make -j4
sudo make install

tar cvzf $DIR/dist/openvino_2022.3.1.tar.gz /opt/intel/openvino_2022.3.1 --owner=0 --group=0 --no-same-owner --no-same-permissions

sudo ln -sf /opt/intel/openvino_2022.3.1 /opt/intel/openvino_2022
sudo ln -sf /opt/intel/openvino_2022.3.1 /opt/intel/openvino