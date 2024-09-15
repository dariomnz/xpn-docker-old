#!/bin/bash
set -x


sudo chown lab:lab /shared

export PATH=/home/lab/bin/openmpi/bin:$PATH                      
export LD_LIBRARY_PATH=/home/lab/bin/openmpi/lib:$LD_LIBRARY_PATH

HOSTFILE=/work/machines_mpi
CONFIGFILE=/shared/config.xml
PRTEFILE=/shared/uriprte.txt

prte --hostfile $HOSTFILE --report-uri $PRTEFILE  &
# prte --hostfile $HOSTFILE --report-uri $PRTEFILE --no-ready-msg &
# sleep 1
SERVER_TYPE=mpi
# SERVER_TYPE=sck
# 1) build configuration file /shared/config.xml
# 2) start mpi_servers in background
NL=$(cat /work/machines_mpi | wc -l)
head -n 1 /work/machines_mpi > /work/machines_mpi1
export XPN_CONF=/shared/config.xml
# export XPN_DEBUG=1
/home/lab/src/xpn/scripts/execute/xpn.sh -e $SERVER_TYPE -w /shared -l /work/machines_mpi -x /tmp -v mk_conf
# sleep 2
export XPN_LOCALITY=0
export XPN_SERVER_SPAWN="/home/lab/bin/xpn/bin/xpn_server_spawn"
hostname

# mpiexec -n 1 \
#         --map-by node:OVERSUBSCRIBE \
#         -x XPN_DNS=/shared/dns.txt  \
#         -x XPN_CONF=/shared/config.xml \
#         -x XPN_LOCALITY=0 \
#         -x XPN_SERVER_SPAWN="/home/lab/bin/xpn/bin/xpn_server_spawn" \
#         -x LD_PRELOAD=/home/lab/bin/xpn/lib64/xpn_bypass.so:$LD_PRELOAD \
#         -x PATH=/home/lab/bin/openmpi/bin:$PATH \
#         -x LD_LIBRARY_PATH=/home/lab/bin/openmpi/lib:$LD_LIBRARY_PATH \
#         /home/lab/src/ior/bin/ior -w -r -o /tmp/expand/xpn/iortest1 -t 100k -b 100k -s 2 -i 1 -d 2 

# export PRTE_MCA_rmaps_default_mapping_policy=node:oversubscribe
# export OMPI_MCA_btl_base_verbose=100
# export OMPI_MCA_btl=tcp,self
# mpiexec -n 1 --display-comm --debug-daemons --verbose --get-stack-traces \
#         --map-by node:OVERSUBSCRIBE \
#         -x XPN_DNS=/shared/dns.txt  \
#         -x XPN_CONF=/shared/config.xml \
#         -x XPN_LOCALITY=0 \
#         -x XPN_SERVER_SPAWN="/home/lab/bin/xpn/bin/xpn_server_spawn" \
#         -x OMPI_MCA_routed=direct \
#         -x PRTE_MCA_routed=direct \
#         -x PRTE_MCA_rmaps_default_mapping_policy=node:oversubscribe \
#         /home/lab/src/xpn/test/performance/xpn/open-write-close /xpn/test 10


# cd /work/xpn/test/integrity/mpi_spawn

# mpicc -g -o child child.c
# mpicc -g -o parent parent.c

# mpiexec -n 1 --with-ft ulfm --map-by node:OVERSUBSCRIBE ./parent
cd /work/xpn/test/integrity/mpi_connect_accept
ompi_info --version
ompi_info


mpicc -g -o client client.c
mpicc -g -o server server.c
mpicc -g -o client-ulfm client-ulfm.c
mpicc -g -o server-ulfm server-ulfm.c
mpicc -g -o server-master server-master.c
mpicc -g -o test test.c

mpiexec -n 1 --dvm file:$PRTEFILE ./server-ulfm > server_port.txt &

sleep 3

mpiexec -n 1 --dvm file:$PRTEFILE ./client-ulfm $(cat server_port.txt | tail -n 1)

# # ssh $(cat $HOSTFILE | tail -n 1) export PATH=/home/lab/bin/openmpi/bin:$PATH; export LD_LIBRARY_PATH=/home/lab/bin/openmpi/lib:$LD_LIBRARY_PATH; HOSTFILE=/work/machines_mpi; CONFIGFILE=/shared/config.xml; PRTEFILE=/shared/uriprte.txt; mpiexec -n 1 --host $(cat $HOSTFILE | tail -n 1)  --with-ft ulfm --verbose --dvm file:$PRTEFILE --debug-daemons --mca btl_base_verbose 100 --mca mpi_ft_verbose 100 --map-by node:OVERSUBSCRIBE ./server-master > server_port.txt &
# mpiexec -n 1 --host $(cat $HOSTFILE | tail -n 1) --dvm file:$PRTEFILE -mca opal_base_verbose 100 -mca pmix_base_verbose info   --with-ft ulfm --verbose --debug-daemons --mca btl_base_verbose 100 --mca mpi_ft_verbose 100 \
#         --map-by node:OVERSUBSCRIBE ./server > server_port.txt &

# sleep 3

# mpiexec -n 1 --with-ft ulfm --dvm file:$PRTEFILE  --verbose --debug-daemons --mca btl_base_verbose 100 --mca mpi_ft_verbose 100 \
#         --map-by node:OVERSUBSCRIBE ./client $(cat server_port.txt | tail -n 1)

# mpiexec -n 1 --with-ft ulfm --map-by node:OVERSUBSCRIBE ./test
# mpiexec -n 1 --host c1de8f727368  --with-ft ulfm --map-by node:OVERSUBSCRIBE ./test
# mpiexec -n 1 --with-ft ulfm --verbose --debug-daemons --mca btl_base_verbose 100 --mca mpi_ft_verbose 100 \
#         --map-by node:OVERSUBSCRIBE ./test
# mpiexec -n 1 --host c1de8f727368  --with-ft ulfm  --verbose --debug-daemons --mca btl_base_verbose 100 --mca mpi_ft_verbose 100 \
#         --map-by node:OVERSUBSCRIBE ./test


netstat -tlnp
# ompi_info --all
# ompi_info --help
pkill mpiexec
pkill prte
