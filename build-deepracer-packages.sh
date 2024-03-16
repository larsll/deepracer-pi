#!/usr/bin/env bash
set -e

export DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

PACKAGES="aws-deepracer-util aws-deepracer-device-console aws-deepracer-core aws-deepracer-sample-models"

while getopts "p:" opt; do
  case $opt in
  p)
    PACKAGES=$OPTARG
    ;;
  \?)
    echo "Invalid option -$OPTARG" >&2
    usage
    ;;
  esac
done

if [ -z "$PACKAGES" ]; then
       echo "No packages provided. Exiting."
       exit 1
fi

# DeepRacer Repos
sudo cp $DIR/files/deepracer.asc /etc/apt/trusted.gpg.d/
sudo cp $DIR/files/aws_deepracer.list /etc/apt/sources.list.d/

# Get mxcam
if [ ! -d "$DIR/deps/geocam-bin-armhf" ]; then
       mkdir -p $DIR/deps/
       cd $DIR/deps/
       git clone https://github.com/doitaljosh/geocam-bin-armhf
fi

rm -rf $DIR/pkg-build/aws* 
mkdir -p $DIR/pkg-build $DIR/pkg-build/src $DIR/dist
cd $DIR/pkg-build
mkdir -p $PACKAGES

# Check which packages we have
cd $DIR/pkg-build/src
for pkg in $PACKAGES;
do
       if [ "$(compgen -G $pkg*.deb | wc -l )" -eq 0 ];
       then
              PACKAGES_DOWNLOAD="$PACKAGES_DOWNLOAD $pkg:amd64"
       fi
done

# Download missing AMD64 packages
if [ -n "$PACKAGES_DOWNLOAD" ];
then
       sudo apt-get update

       echo -e '\n### Downloading original packages ###\n'
       echo "Missing packages: $PACKAGES_DOWNLOAD"
       apt download $PACKAGES_DOWNLOAD
fi

# Build required packages
cd $DIR/pkg-build
for pkg in $PACKAGES; 
do
       if [ "$pkg" == "aws-deepracer-util" ];
       then
              VERSION=$(jq -r ".[\"aws-deepracer-util\"]" $DIR/versions.json)
              echo -e "\n### Building aws-deepracer-util $VERISON ###\n"
              dpkg-deb -R src/aws-deepracer-util_*amd64.deb aws-deepracer-util
              cd aws-deepracer-util
              rm -rf opt/aws/deepracer/camera/installed/bin/mxuvc \
                     opt/aws/deepracer/camera/installed/bin/querydump \
                     opt/aws/deepracer/camera/installed/lib
              cp $DIR/deps/geocam-bin-armhf/files/usr/bin/mxcam opt/aws/deepracer/camera/installed/bin
              cp $DIR/files/aws_deepracer-community.list etc/apt/sources.list.d/aws_deepracer.list
              sed -i 's/Architecture: amd64/Architecture: arm64/' DEBIAN/control
              sed -i "s/Version: .*/Version: $VERSION/" DEBIAN/control
              sed -i 's/pyclean/\/usr\/local\/bin\/pyclean/' DEBIAN/prerm
              cd ..
              dpkg-deb --root-owner-group -b aws-deepracer-util
              dpkg-name -o aws-deepracer-util.deb
              FILE=$(compgen -G aws-deepracer-util*.deb)
              mv $FILE $(echo $DIR/dist/$FILE | sed -e 's/\+/\-/')
       fi

       if [ "$pkg" == "aws-deepracer-device-console" ];
       then
              VERSION=$(jq -r ".[\"aws-deepracer-device-console\"]" $DIR/versions.json)
              echo -e "\n### Building aws-deepracer-device-console $VERSION ###\n"
              dpkg-deb -R src/aws-deepracer-device-console_*amd64.deb aws-deepracer-device-console
              cd aws-deepracer-device-console
              sed -i 's/Architecture: amd64/Architecture: arm64/' DEBIAN/control
              sed -i "s/Version: .*/Version: $VERSION/" DEBIAN/control
              echo "/opt/aws/deepracer/nginx/nginx_install_certs.sh" | tee -a DEBIAN/postinst >/dev/null
              echo "systemctl restart nginx.service" | tee -a DEBIAN/postinst >/dev/null
              cd ..
              dpkg-deb --root-owner-group -b aws-deepracer-device-console
              dpkg-name -o aws-deepracer-device-console.deb 
              FILE=$(compgen -G aws-deepracer-device-console*.deb)
              mv $FILE $(echo $DIR/dist/$FILE | sed -e 's/\+/\-/')
       fi

       if [ "$pkg" == "aws-deepracer-core" ];
       then
              VERSION=$(jq -r ".[\"aws-deepracer-core\"]" $DIR/versions.json)
              echo -e "\n### Building aws-deepracer-core $VERSION ###\n"
              dpkg-deb -R src/aws-deepracer-core_*amd64.deb aws-deepracer-core
              cd aws-deepracer-core
              sed -i 's/Architecture: amd64/Architecture: arm64/' DEBIAN/control
              sed -i "s/Version: .*/Version: $VERSION/" DEBIAN/control
              sed -i 's/python-apt/python3-apt/' DEBIAN/control
              sed -i '/Depends/ s/$/, gnupg/' DEBIAN/control
              sed -i 's/pyclean/\/usr\/local\/bin\/pyclean/' DEBIAN/prerm
              sed -i 's/ExecStop=\/opt\/aws\/deepracer\/util\/otg_eth.sh stop/KillSignal=2/' etc/systemd/system/deepracer-core.service
              rm -rf opt/aws/deepracer/lib/*
              cp $DIR/files/start_ros.sh opt/aws/deepracer
              cp -r $DIR/bundle_ws/install/* opt/aws/deepracer/lib/
              rm DEBIAN/preinst
              cd ..
              dpkg-deb --root-owner-group -b aws-deepracer-core
              dpkg-name -o aws-deepracer-core.deb 
              FILE=$(compgen -G aws-deepracer-core*.deb)
              mv $FILE $(echo $DIR/dist/$FILE | sed -e 's/\+/\-/')
       fi

       if [ "$pkg" == "aws-deepracer-sample-models" ];
       then
              VERSION=$(jq -r ".[\"aws-deepracer-sample-models\"]" $DIR/versions.json)
              echo -e "\n### Building aws-deepracer-sample-models $VERISON ###\n"
              dpkg-deb -R src/aws-deepracer-sample-models_*amd64.deb aws-deepracer-sample-models
              cd aws-deepracer-sample-models
              sed -i 's/Architecture: amd64/Architecture: all/' DEBIAN/control
              sed -i "s/Version: .*/Version: $VERSION/" DEBIAN/control
              cd ..
              dpkg-deb --root-owner-group -b aws-deepracer-sample-models
              dpkg-name -o aws-deepracer-sample-models.deb 
              FILE=$(compgen -G aws-deepracer-sample-models*.deb)
              mv $FILE $(echo $DIR/dist/$FILE | sed -e 's/\+/\-/')
       fi
done