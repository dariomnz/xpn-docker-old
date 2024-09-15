#!/bin/bash
set -x


sudo chown lab:lab /shared

sudo chown -R lab:lab /home/lab/src/xpn/test/integrity/mpi_fault_tolerant

HOSTFILE=/work/machines_mpi
CONFIGFILE=/shared/config.xml
PRTEFILE=/shared/uriprte.txt

export PATH=/home/lab/bin/openmpi/bin:$PATH                      
export LD_LIBRARY_PATH=/home/lab/bin/openmpi/lib:$LD_LIBRARY_PATH

sleep 1
# cd /home/lab/src/xpn/test/integrity/mpi_fault_tolerant/api
# for file in *.c; do
#     filename=$(basename "$file" .c)
#     mpicc -o "$filename" "$file"
#     mpiexec --timeout 5 --map-by :OVERSUBSCRIBE --with-ft ulfm "$filename" -v
#     sleep 1
# done
cd /home/lab/src/xpn/test/integrity/mpi_fault_tolerant/benchmarks
for file in *.c; do
    filename=$(basename "$file" .c)
    mpicc -o "$filename" "$file" -lm
    mpiexec --timeout 5 --map-by :OVERSUBSCRIBE --with-ft ulfm "$filename" -v
    sleep 1
done
cd /home/lab/src/xpn/test/integrity/mpi_fault_tolerant/stress
for file in *.c; do
    filename=$(basename "$file" .c)
    mpicc -o "$filename" "$file" -lm
    mpiexec --timeout 5 --map-by :OVERSUBSCRIBE --with-ft ulfm "$filename" -v
    sleep 1
done
cd /home/lab/src/xpn/test/integrity/mpi_fault_tolerant/tutorial
for file in *.c; do
    filename=$(basename "$file" .c)
    mpicc -o "$filename" "$file" -lm
    mpiexec --timeout 5 --map-by :OVERSUBSCRIBE --with-ft ulfm "$filename" -v
    sleep 1
done





# SERVER_TYPE=mpi
# # SERVER_TYPE=sck
# # 1) build configuration file /shared/config.xml
# # 2) start mpi_servers in background
# NL=$(cat /work/machines_mpi | wc -l)

# # export XPN_SCK_PORT=5555 
# export XPN_DNS=/shared/dns.txt 
# export XPN_CONF=/shared/config.xml

# # export PRTE_MCA_rmaps_default_mapping_policy=node:oversubscribe

# prte --hostfile $HOSTFILE --report-uri $PRTEFILE --no-ready-msg &

# sleep 2
# /home/lab/src/xpn/scripts/execute/xpn.sh -e $SERVER_TYPE -w /shared -l /work/machines_mpi -x /tmp -n $NL -v mk_conf

# mpiexec -np       $NL \
#         --dvm file:$PRTEFILE \
#         --hostfile        /work/machines_mpi \
#         --map-by node \
#         /home/lab/bin/xpn/bin/xpn_server &

# sleep 2
# # export XPN_DEBUG=1
# export XPN_LOCALITY=0
# # export XPN_THREAD=1
# # 3) start xpn client
# # mpiexec -l -np $NL \
# mpiexec --version
# mpiexec -n $NL --output TAG-DETAILED -mca routed direct \
#         --dvm file:$PRTEFILE \
#         --map-by node:OVERSUBSCRIBE \
#         --hostfile        /work/machines_mpi \
#         -x XPN_DNS=/shared/dns.txt  \
#         -x XPN_CONF=/shared/config.xml \
#         -x XPN_LOCALITY=0 \
#         -x LD_PRELOAD=/home/lab/bin/xpn/lib64/xpn_bypass.so:$LD_PRELOAD \
#         -x PATH=/home/lab/bin/openmpi/bin:$PATH \
#         -x LD_LIBRARY_PATH=/home/lab/bin/openmpi/lib:$LD_LIBRARY_PATH \
#         /home/lab/src/ior/bin/ior -w -r -o /tmp/expand/xpn/iortest1 -t 100k -b 100k -s 10 -i 1 -d 2 
# # export XPN_DEBUG=1
# # unset XPN_DEBUG
# mpiexec -n $NL --output TAG-DETAILED -mca routed direct \
#         --dvm file:$PRTEFILE \
#         --map-by node:OVERSUBSCRIBE \
#         --hostfile        /work/machines_mpi \
#         -x XPN_DNS=/shared/dns.txt  \
#         -x XPN_CONF=/shared/config.xml \
#         -x XPN_LOCALITY=0 \
#         -x LD_PRELOAD=/home/lab/bin/xpn/lib64/xpn_bypass.so:$LD_PRELOAD \
#         /home/lab/src/ior/bin/mdtest -d /tmp/expand/xpn -I 5 -z 1 -b 2 -u -e 100k -w 200k

# # ls -rlash /tmp
# # netstat -tlnp
# # 4) stop mpi_servers
# /home/lab/src/xpn/scripts/execute/xpn.sh -e $SERVER_TYPE -w /shared -d /work/machines_mpi stop
# sleep 5
# netstat -tlnp

# pkill mpiexec
