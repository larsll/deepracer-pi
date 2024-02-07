#!/usr/bin/env bash
set -e

export DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# DeepRacer Repos
sudo cp $DIR/files/deepracer.asc /etc/apt/trusted.gpg.d/
sudo cp $DIR/files/aws_deepracer.list /etc/apt/sources.list.d/
sudo apt-get update

# Get mxcam
cd $DIR/deps/
git clone https://github.com/doitaljosh/geocam-bin-armhf

rm -rf $DIR/pkg-build
mkdir -p $DIR/pkg-build
cd $DIR/pkg-build
mkdir -p aws-deepracer-util aws-deepracer-device-console aws-deepracer-core aws-deepracer-sample-models
apt download aws-deepracer-util:amd64 aws-deepracer-device-console:amd64 aws-deepracer-core:amd64 aws-deepracer-sample-models:amd64

dpkg-deb -R aws-deepracer-util_*amd64.deb aws-deepracer-util
cd aws-deepracer-util
rm -rf opt/aws/deepracer/camera/installed/bin/mxuvc \
       opt/aws/deepracer/camera/installed/bin/querydump \
       opt/aws/deepracer/camera/installed/lib
cp $DIR/deps/geocam-bin-armhf/files/usr/bin/mxcam opt/aws/deepracer/camera/installed/bin
sed -i 's/Architecture: amd64/Architecture: arm64/' DEBIAN/control
cd ..
dpkg-deb -b aws-deepracer-util
dpkg-name -o aws-deepracer-util.deb

dpkg-deb -R aws-deepracer-device-console_*amd64.deb aws-deepracer-device-console
cd aws-deepracer-device-console
sed -i 's/Architecture: amd64/Architecture: arm64/' DEBIAN/control
echo "/opt/aws/deepracer/nginx/nginx_install_certs.sh" | tee -a DEBIAN/postinst
echo "systemctl status nginx.service" | tee -a DEBIAN/postinst
cd ..
dpkg-deb -b aws-deepracer-device-console
dpkg-name -o aws-deepracer-device-console.deb

dpkg-deb -R aws-deepracer-core_*amd64.deb aws-deepracer-core
cd aws-deepracer-core
sed -i 's/Architecture: amd64/Architecture: arm64/' DEBIAN/control
sed -i 's/Version: 2.0.383.0/Version: 2.0.383.1+community/' DEBIAN/control
rm -rf opt/aws/deepracer/lib/*
cp $DIR/files/start_ros.sh opt/aws/deepracer
cp -r $DIR/deps/deepracer-scripts/ws/install/* opt/aws/deepracer/lib/
rm DEBIAN/preinst
cd ..
dpkg-deb -b aws-deepracer-core
dpkg-name -o aws-deepracer-core.deb

dpkg-deb -R aws-deepracer-sample-models_*amd64.deb aws-deepracer-sample-models
cd aws-deepracer-sample-models
sed -i 's/Architecture: amd64/Architecture: all/' DEBIAN/control
cd ..
dpkg-deb -b aws-deepracer-sample-models
dpkg-name -o aws-deepracer-sample-models.deb
