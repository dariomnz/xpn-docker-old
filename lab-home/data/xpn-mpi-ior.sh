#!/bin/bash
set -x


sudo chown lab:lab /shared

# 1) build configuration file /shared/config.xml
# 2) start mpi_servers in background
NL=$(cat /work/machines_mpi | wc -l)
export XPN_DNS=/shared/dns.txt 
export XPN_CONF=/shared/config.xml
/home/lab/src/xpn/scripts/execute/xpn.sh -w /shared -l /work/machines_mpi -x /tmp/ -n $NL start
# export XPN_DEBUG=1
# 3) start xpn client
mpiexec -l -np 3 \
        -hostfile        /work/machines_mpi \
        -genv XPN_DNS    /shared/dns.txt  \
        -genv XPN_CONF   /shared/config.xml \
        -genv LD_PRELOAD /home/lab/bin/xpn/lib64/xpn_bypass.so:$LD_PRELOAD \
        /home/lab/src/ior/bin/ior -w -r -o /tmp/expand/xpn/iortest -t 64k -b 64k -s 10 -i 1 -d 2 -k

mpiexec -l -np 3 \
        -hostfile        /work/machines_mpi \
        -genv XPN_DNS    /shared/dns.txt  \
        -genv XPN_CONF   /shared/config.xml \
        -genv LD_PRELOAD /home/lab/bin/xpn/lib64/xpn_bypass.so:$LD_PRELOAD \
        /home/lab/src/ior/bin/mdtest -d /tmp/expand/xpn -I 5 -z 1 -b 2 -u -e 1m -w 2m 

ls -rlash /tmp

# 4) stop mpi_servers
/home/lab/src/xpn/scripts/execute/xpn.sh -w /shared -d /work/machines_mpi stop

