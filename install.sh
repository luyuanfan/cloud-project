#!/bin/bash
set -e
exec > >(tee -i install.log)
exec 2>&1

# Version definitions
OMNET_VERSION="5.6.2"
INET_VERSION="4.2.5"
INET_QUIC_VERSION="4.2.5"
PROJECT_ROOT="$(pwd)"
OMNET_DIR="$(pwd)/omnetpp_env"

# Make main library folder
mkdir -p $OMNET_DIR
cd $OMNET_DIR

# Install and build OMNeT++ (from wget omnetpp 5.6.2 release)
#   Install ref: https://github.com/omnetpp/omnetpp/releases/tag/omnetpp-5.4.2
#   Build ref: https://networksimulationtools.com/how-to-use-inet-framework-in-omnet/
echo "Installing OMNeT++ $OMNET_VERSION"
if [ ! -d "omnetpp-${OMNET_VERSION}" ]; then
    wget https://github.com/omnetpp/omnetpp/releases/download/omnetpp-${OMNET_VERSION}/omnetpp-${OMNET_VERSION}-src-core.tgz 
    tar -xvzf omnetpp-${OMNET_VERSION}-src-core.tgz
    rm omnetpp-${OMNET_VERSION}-src-core.tgz
fi
cd omnetpp-${OMNET_VERSION}
. setenv
./configure WITH_TKENV=no WITH_QTENV=no WITH_OSG=no
make -j $(nproc)

# Go back to omnetpp_env
cd $OMNET_DIR

# Install and build INET (from wget inet v4.2.5 release)
#   NOTE: tarball untars to inet-4, so we change that part
#   Install ref: https://github.com/inet-framework/inet/releases/tag/v4.2.5
#   Build ref: https://github.com/inet-framework/inet/blob/master/INSTALL.md
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
python3 -m ensurepip --upgrade
python3 -m pip install --upgrade pip setuptools wheel
python3 -m pip install -r python/requirements.txt
make makefiles
make -j $(nproc)

# Go back to omnetpp_env
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