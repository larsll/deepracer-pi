#!/usr/bin/env bash
set -e

mkdir -p ~/deepracer-pi/build
cd ~/deepracer-pi/build
mkdir -p aws-deepracer-util aws-deepracer-device-console aws-deepracer-core aws-deepracer-sample-models
apt download aws-deepracer-util:amd64 aws-deepracer-device-console:amd64 aws-deepracer-core:amd64 aws-deepracer-sample-models:amd64

dpkg-deb -R aws-deepracer-util_*amd64.deb aws-deepracer-util
cd aws-deepracer-util
rm -rf opt/aws/deepracer/camera/installed/bin/mxuvc \
       opt/aws/deepracer/camera/installed/bin/querydump \
       opt/aws/deepracer/camera/installed/lib
cp ~/geocam-bin-armhf/files/usr/bin/mxcam opt/aws/deepracer/camera/installed/bin

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
cp -r ~/deepracer-scripts/ws/install/* opt/aws/deepracer/lib/
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
