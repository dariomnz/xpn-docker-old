#!/bin/bash
set -x


sudo chown lab:lab /shared

# sudo chown -R lab:lab /home/lab/src/

HOSTFILE=/work/machines_mpi
CONFIGFILE=/shared/config.xml
PRTEFILE=/shared/uriprte.txt

export PATH=/home/lab/bin/openmpi/bin:$PATH                      
export LD_LIBRARY_PATH=/home/lab/bin/openmpi/lib:$LD_LIBRARY_PATH

sleep 1
NL=$(cat /work/machines_mpi | wc -l)

prte --hostfile $HOSTFILE --report-uri $PRTEFILE &

sleep 2
# cd /work/xpn/test/integrity/mpi_connect_accept
# cd /home/dario/lab-docker/xpn/test/integrity/mpi_connect_accept

# mpicc -o client-ulfm client-ulfm.c
# mpicc -o server-ulfm server-ulfm.c
# mpicc -o test test.c

# export MPICH_ABORT_ON_ERROR=0
# export MPICH_DEBUG=1
# export MPICH_DEBUG_VERBOSE=1
# export MPIR_CVAR_ENABLE_FT=1
# export MPICH_ENABLE_FT=1

# mpiexec --version

# mpiexec -n 4 -disable-auto-cleanup ./test
# mpiexec -n 3 ./test




# mpiexec -n 1 -disable-auto-cleanup \
#         --map-by node:OVERSUBSCRIBE \
#         -genv MPIR_CVAR_ENABLE_FT=1 \
#         ./server-ulfm > server_port.txt &

# mpiexec -n 1 \
#         --dvm file:$PRTEFILE \
#         --map-by node:OVERSUBSCRIBE \
#         --with-ft ulfm \
#         server-ulfm > server_port.txt &

# sleep 1

# mpiexec -n 1 -disable-auto-cleanup \
#         --map-by node:OVERSUBSCRIBE \
#         -genv MPIR_CVAR_ENABLE_FT=1 \
#         ./client-ulfm $(cat server_port.txt)
# mpiexec -n 1 -mca routed direct \
#         --dvm file:$PRTEFILE \
#         --map-by node:OVERSUBSCRIBE \
#         --with-ft ulfm \
#         ./client-ulfm $(cat server_port.txt)



/home/lab/src/xpn/scripts/execute/xpn.sh -w /shared -l /work/machines_mpi -x /tmp -n $NL -p 1 -v mk_conf
for ((i=1; i<=$NL; i++))
do
        line=$(head -n $i "/work/machines_mpi" | tail -n 1)
        mpiexec -np       1 --enable-recovery \
        --host "${line}" \
        --dvm file:$PRTEFILE \
        --map-by node \
        --with-ft ulfm \
        /home/lab/bin/xpn/bin/xpn_server  &
done


# mpiexec -np       $NL \
#         --dvm file:$PRTEFILE \
#         --hostfile        /work/machines_mpi \
#         --map-by node \
#         --with-ft ulfm \
#         /home/lab/bin/xpn/bin/xpn_server &

sleep 5
export XPN_DEBUG=1
export XPN_LOCALITY=0
# export XPN_THREAD=1
# 3) start xpn client
# mpiexec -l -np $NL \
mpiexec --version

(sleep 2 && mpiexec --host $(tail -n 1 /work/machines_mpi) pkill xpn_server && mpiexec --host $(tail -n 1 /work/machines_mpi) netstat -tlnp ) &
timestamp=$(date +%s)
mpiexec -n 2 --output TAG-DETAILED -mca routed direct \
        --dvm file:$PRTEFILE \
        --map-by node:OVERSUBSCRIBE \
        --hostfile        /work/machines_mpi \
        --with-ft ulfm \
        -x XPN_DNS=/shared/dns.txt  \
        -x XPN_CONF=/shared/config.xml \
        -x XPN_LOCALITY=0 \
        -x LD_PRELOAD=/home/lab/bin/xpn/lib64/xpn_bypass.so:$LD_PRELOAD \
        -x PATH=/home/lab/bin/openmpi/bin:$PATH \
        -x LD_LIBRARY_PATH=/home/lab/bin/openmpi/lib:$LD_LIBRARY_PATH \
        /home/lab/src/ior/bin/ior -w -W -G ${timestamp} -r -R -o /tmp/expand/xpn/iortest1 -t 100k -b 100k -s 100 -i 1 -d 2 
# export XPN_DEBUG=1
# unset XPN_DEBUG
# mpiexec -n $NL --output TAG-DETAILED -mca routed direct \
#         --dvm file:$PRTEFILE \
#         --map-by node:OVERSUBSCRIBE \
#         --hostfile        /work/machines_mpi \
#         -x XPN_DNS=/shared/dns.txt  \
#         -x XPN_CONF=/shared/config.xml \
#         -x XPN_LOCALITY=0 \
#         -x LD_PRELOAD=/home/lab/bin/xpn/lib64/xpn_bypass.so:$LD_PRELOAD \
#         /home/lab/src/ior/bin/mdtest -d /tmp/expand/xpn -I 5 -z 1 -b 2 -u -e 100k -w 200k

# ls -rlash /tmp
# netstat -tlnp
# 4) stop mpi_servers
/home/lab/src/xpn/scripts/execute/xpn.sh -w /shared -d /work/machines_mpi stop
sleep 5
netstat -tlnp

# pkill mpiexec
