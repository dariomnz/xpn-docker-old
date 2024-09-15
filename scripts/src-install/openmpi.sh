#!/bin/bash
set -x

# 1) Check arguments
if [ $# -lt 1 ]; then
	echo "Usage: $0 <full path where software will be downloaded>"
	exit
fi

# 2) Clean-up
DESTINATION_PATH=$1
apt install -y flex

# 3) Download OPENMPI
mkdir -p ${DESTINATION_PATH}
cd       ${DESTINATION_PATH}
git clone --depth 1 --recursive https://github.com/open-mpi/ompi.git
ln   -s ompi  openmpi

# wget https://download.open-mpi.org/nightly/open-mpi/v5.0.x/openmpi-v5.0.x-202406110241-2a43602.tar.gz
# tar zxf openmpi-v5.0.x-202406110241-2a43602.tar.gz
# ln   -s openmpi-v5.0.x-202406110241-2a43602  openmpi
# wget https://download.open-mpi.org/release/open-mpi/v5.0/openmpi-5.0.3.tar.gz
# tar zxf openmpi-5.0.3.tar.gz
# ln   -s openmpi-5.0.3  openmpi

# 4) Install OPENMPI (from source code)
mkdir -p /home/lab/bin
cd       ${DESTINATION_PATH}/openmpi

cd 3rd-party
rm -rf prrte
git clone --depth 1 --recursive https://github.com/openpmix/prrte.git

# cd ../openpmix
# git checkout e32e0179  
export AUTOMAKE_JOBS=4
cd ..
echo $(pwd)
./autogen.pl

./configure --prefix=/home/lab/bin/openmpi
make -j $(nproc) all
make install

# 5) PATH
# echo "# OPENMPI"                                                          >> /home/lab/.profile
# echo "export PATH=/home/lab/bin/openmpi/bin:\$PATH"                       >> /home/lab/.profile
# echo "export LD_LIBRARY_PATH=/home/lab/bin/openmpi/lib:\$LD_LIBRARY_PATH" >> /home/lab/.profile

