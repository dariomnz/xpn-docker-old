#!/bin/bash
set -x

# 1) Check arguments
if [ $# -lt 1 ]; then
	echo "Usage: $0 <full path where software will be downloaded>"
	exit
fi

# 2) Clean-up
DESTINATION_PATH=$1

# 3) Download OPENMPI
mkdir -p ${DESTINATION_PATH}
cd       ${DESTINATION_PATH}
git clone --depth 1 --recursive https://github.com/ofiwg/libfabric.git


# 4) Install libfabric (from source code)
mkdir -p /home/lab/bin
cd       ${DESTINATION_PATH}/libfabric

export AUTOMAKE_JOBS=4
echo $(pwd)

./autogen.sh

./configure --prefix=/home/lab/bin/libfabric --enable-debug
make -j $(nproc) all
make install



# 5) PATH
echo "# libfabric"                                                          >> /home/lab/.profile
echo "export PATH=/home/lab/bin/libfabric/bin:\$PATH"                       >> /home/lab/.profile
echo "export LD_LIBRARY_PATH=/home/lab/bin/libfabric/lib:\$LD_LIBRARY_PATH" >> /home/lab/.profile
