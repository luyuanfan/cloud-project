#!/bin/bash

# Log file
set -e
exec > >(tee -i install.log)
exec 2>&1

# Specify versions 
OMNET_VERSION="5.6.2"
INET_VERSION="4.2.5"
INET_QUIC_VERSION="4.2.5"
PROJECT_ROOT="$(pwd)"
OMNET_DIR="$(pwd)/omnetpp_env"

mkdir -p $OMNET_DIR
cd $OMNET_DIR

# Install and build OMNeT++ (from wget omnetpp 5.6.2 release)
echo "Installing OMNeT++ $OMNET_VERSION"
if [ ! -d "omnetpp-${OMNET_VERSION}" ]; then
    wget https://github.com/omnetpp/omnetpp/releases/download/omnetpp-${OMNET_VERSION}/omnetpp-${OMNET_VERSION}-src-core.tgz 
    tar -xvzf omnetpp-${OMNET_VERSION}-src-core.tgz
    rm omnetpp-${OMNET_VERSION}-src-core.tgz
fi
cd omnetpp-${OMNET_VERSION}
. setenv
sed 's/WITH_TKENV=yes/WITH_TKENV=no/' configure.user
sed 's/WITH_QTENV=yes/WITH_QTENV=no/' configure.user
sed 's/WITH_OSG=yes/WITH_OSG=no/' configure.user
./configure
make -j $(nproc)

cd $OMNET_DIR

# Install and build INET (from wget inet v4.2.5 release)
echo "Installing INET $INET_VERSION"
if [ ! -d "inet-${INET_VERSION}" ]; then
    wget https://github.com/inet-framework/inet/releases/download/v${INET_VERSION}/inet-${INET_VERSION}-src.tgz
    mkdir inet-${INET_VERSION}
    tar -xvzf inet-${INET_VERSION}-src.tgz -C inet-${INET_VERSION} --strip-components=1
    rm inet-${INET_VERSION}-src.tgz
fi
cd omnetpp-${OMNET_VERSION}
. setenv
cd ../inet-${INET_VERSION}
make makefiles
make -j $(nproc)

cd $OMNET_DIR

# Install inet-quic (from GitHub inet-quic branch v4.2.5)
echo "Installing INET-QUIC ${INET_QUIC_VERSION}"
if [ ! -d "inet-quic" ]; then
  git clone git@github.com:inet-framework/inet-quic.git
fi
cd inet-quic
git fetch --all --tags
git checkout "v${INET_QUIC_VERSION}"
cd ../omnetpp-${OMNET_VERSION}
. setenv
cd ../inet-quic
make makefiles
make -j $(nproc)

# Go back to project root folder
cd $PROJECT_ROOT

echo "All installation is complete"