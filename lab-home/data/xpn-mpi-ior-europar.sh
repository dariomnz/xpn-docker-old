#!/bin/bash
set -x


sudo chown lab:lab /shared

sleep 1
SERVER_TYPE=mpi
# SERVER_TYPE=sck
# 1) build configuration file /shared/config.xml
# 2) start mpi_servers in background
NL=$(cat /work/machines_mpi | wc -l)

# export XPN_SCK_PORT=5555 
export XPN_DNS=/shared/dns.txt 
# export XPN_DEBUG=1
export XPN_CONF=/shared/config.xml
/home/lab/src/xpn/scripts/execute/xpn.sh -e $SERVER_TYPE -w /shared -l /work/machines_mpi -x /tmp -n $NL -v start
sleep 2
export XPN_LOCALITY=1
# export XPN_THREAD=1
# 3) start xpn client
mpiexec -l -np $NL \
        -hostfile        /work/machines_mpi \
        -genv XPN_DNS    /shared/dns.txt  \
        -genv XPN_CONF   /shared/config.xml \
        -genv LD_PRELOAD /home/lab/bin/xpn/lib64/xpn_bypass.so:$LD_PRELOAD \
        /home/lab/src/ior/bin/ior -w -r -o /tmp/expand/xpn/iortest1 -t 512k -b 1g -s 1 -i 2 -d 2 

# ls -rlash /tmp
# netstat -tlnp
# 4) stop mpi_servers
/home/lab/src/xpn/scripts/execute/xpn.sh -e $SERVER_TYPE -w /shared -d /work/machines_mpi stop
sleep 5
# netstat -tlnp

pkill mpiexec
