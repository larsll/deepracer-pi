#!/usr/bin/env bash
set -e

export DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# DeepRacer Repos
sudo cp $DIR/files/deepracer.asc /etc/apt/trusted.gpg.d/
sudo cp $DIR/files/aws_deepracer.list /etc/apt/sources.list.d/
sudo apt-get update

# Get mxcam
if [ ! -d "$DIR/deps/geocam-bin-armhf" ]; then
       mkdir -p $DIR/deps/
       cd $DIR/deps/
       git clone https://github.com/doitaljosh/geocam-bin-armhf
fi

rm -rf $DIR/pkg-build
mkdir -p $DIR/pkg-build $DIR/dist
cd $DIR/pkg-build
mkdir -p aws-deepracer-util aws-deepracer-device-console aws-deepracer-core aws-deepracer-sample-models

echo -e '\n### Downloading original packages ###\n'
apt download aws-deepracer-util:amd64 aws-deepracer-device-console:amd64 aws-deepracer-core:amd64 aws-deepracer-sample-models:amd64

VERSION=$(jq -r ".[\"aws-deepracer-util\"]" $DIR/versions.json)
echo -e "\n### Building aws-deepracer-util $VERISON ###\n"
dpkg-deb -R aws-deepracer-util_*amd64.deb aws-deepracer-util
cd aws-deepracer-util
rm -rf opt/aws/deepracer/camera/installed/bin/mxuvc \
       opt/aws/deepracer/camera/installed/bin/querydump \
       opt/aws/deepracer/camera/installed/lib
cp $DIR/deps/geocam-bin-armhf/files/usr/bin/mxcam opt/aws/deepracer/camera/installed/bin
sed -i 's/Architecture: amd64/Architecture: arm64/' DEBIAN/control
sed -i "s/Version: .*/Version: $VERSION/" DEBIAN/control
sed -i 's/pyclean/\/usr\/local\/bin\/pyclean/' DEBIAN/prerm
cd ..
dpkg-deb --root-owner-group -b aws-deepracer-util
dpkg-name -o aws-deepracer-util.deb 
mv aws-deepracer-util_*_arm64.deb $DIR/dist/

VERSION=$(jq -r ".[\"aws-deepracer-device-console\"]" $DIR/versions.json)
echo -e "\n### Building aws-deepracer-device-console $VERSION ###\n"
dpkg-deb -R aws-deepracer-device-console_*amd64.deb aws-deepracer-device-console
cd aws-deepracer-device-console
sed -i 's/Architecture: amd64/Architecture: arm64/' DEBIAN/control
sed -i "s/Version: .*/Version: $VERSION/" DEBIAN/control
echo "/opt/aws/deepracer/nginx/nginx_install_certs.sh" | tee -a DEBIAN/postinst >/dev/null
echo "systemctl restart nginx.service" | tee -a DEBIAN/postinst >/dev/null
cd ..
dpkg-deb --root-owner-group -b aws-deepracer-device-console
dpkg-name -o aws-deepracer-device-console.deb 
mv aws-deepracer-device-console_*_arm64.deb $DIR/dist/

VERSION=$(jq -r ".[\"aws-deepracer-core\"]" $DIR/versions.json)
echo -e "\n### Building aws-deepracer-core $VERSION ###\n"
dpkg-deb -R aws-deepracer-core_*amd64.deb aws-deepracer-core
cd aws-deepracer-core
sed -i 's/Architecture: amd64/Architecture: arm64/' DEBIAN/control
sed -i "s/Version: .*/Version: $VERSION/" DEBIAN/control
sed -i 's/python-apt/python3-apt/' DEBIAN/control
rm -rf opt/aws/deepracer/lib/*
cp $DIR/files/start_ros.sh opt/aws/deepracer
cp -r $DIR/bundle_ws/install/* opt/aws/deepracer/lib/
rm DEBIAN/preinst
cd ..
dpkg-deb --root-owner-group -b aws-deepracer-core
dpkg-name -o aws-deepracer-core.deb 
mv aws-deepracer-core_*_arm64.deb $DIR/dist/

VERSION=$(jq -r ".[\"aws-deepracer-sample-models\"]" $DIR/versions.json)
echo -e "\n### Building aws-deepracer-sample-models $VERISON ###\n"
dpkg-deb -R aws-deepracer-sample-models_*amd64.deb aws-deepracer-sample-models
cd aws-deepracer-sample-models
sed -i 's/Architecture: amd64/Architecture: all/' DEBIAN/control
sed -i "s/Version: .*/Version: $VERSION/" DEBIAN/control
cd ..
dpkg-deb --root-owner-group -b aws-deepracer-sample-models
dpkg-name -o aws-deepracer-sample-models.deb 
mv aws-deepracer-sample-models_*_all.deb $DIR/dist/
