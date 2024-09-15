#!/bin/bash
set -x


sudo chown lab:lab /shared

export PATH=/home/lab/bin/openmpi/bin:$PATH                      
export LD_LIBRARY_PATH=/home/lab/bin/openmpi/lib:$LD_LIBRARY_PATH

HOSTFILE=/work/machines_mpi
CONFIGFILE=/shared/config.xml
PRTEFILE=/shared/uriprte.txt

# prte --hostfile $HOSTFILE --report-uri $PRTEFILE --system-server &

sleep 2
cd /work/xpn/test/integrity/mpi_spawn
# ompi_info --version
# ompi_info

# mpicc -g -o test test.c
# mpicc -g -o test2 test2.c
# mpicc -g -o child2 child2.c
# mpicc -g -o parent2 parent2.c
mpicc -g -o spawn spawn.c
mpicc -g -o spawn-ulfm spawn-ulfm.c

# export PMIX_MCA_gds=hash

# mpiexec -n 3 --map-by node:OVERSUBSCRIBE ./spawn
# mpiexec -n 3 --hostfile /work/machines_mpi --map-by node:OVERSUBSCRIBE ./spawn
# mpiexec -n 3 --map-by node:OVERSUBSCRIBE ./test2 -v
# mpiexec -n 3 --hostfile /work/machines_mpi --with-ft ulfm --map-by node:OVERSUBSCRIBE ./spawn-ulfm  -v
mpiexec -n 3  --with-ft ulfm --map-by node:OVERSUBSCRIBE ./spawn-ulfm -v


netstat -tlnp
# ompi_info --all
# ompi_info --help
# pkill mpiexec
# pkill prte
# pkill prterun
