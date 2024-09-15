#!/bin/bash
set -x

sudo chown lab:lab /shared
# 1) build configuration file /shared/config.txt
# 2) start mpi_servers in background
NL=$(cat /work/machines_mpi | wc -l)
REPLICATION_LEVEL=0

# Build hostlist
hostlist=""

while IFS= read -r line || [ -n "$line" ]; do
    hostlist="$hostlist,$line"
done < "/work/machines_mpi"

hostlist="${hostlist:1}"

# hostlist_minus=$(echo "$hostlist" | rev | cut -d',' -f2- | rev)
hostlist_minus=$(echo "$hostlist" | cut -d',' -f2-)
hostlist_minus2=$(echo "$hostlist_minus" | cut -d',' -f2-)
timestamp=$(date +%s)
file_size=121m
# export XPN_DEBUG=1
export XPN_CONF=/shared/config.txt
# export XPN_LOCALITY=1
sleep 2
mpiexec -l -np 3 \
        -hostfile        /work/machines_mpi \
        mkdir -p /tmp/expand/data/1
mpiexec -l -np 3 \
        -hostfile        /work/machines_mpi \
        mkdir -p /tmp/expand/data/2

/home/lab/src/xpn/admire/io-scheduler/expand.sh --hosts ${hostlist} --shareddir "/shared/" --replication_level ${REPLICATION_LEVEL} start 
# cat /shared/dns.txt
# sleep 2


# /home/lab/src/xpn/scripts/execute/xpn.sh -s /home/lab/data -x /tmp/expand/data -l /work/machines_mpi -n $NL -p $REPLICATION_LEVEL preload

# sleep 5
# export XPN_DEBUG=1
mpiexec -l -np 3 \
        -hostfile        /work/machines_mpi \
        -genv XPN_CONF   /shared/config.txt \
        -genv LD_PRELOAD /home/lab/bin/xpn/lib64/xpn_bypass.so:$LD_PRELOAD \
        /home/lab/src/ior/bin/ior -w -W -G ${timestamp} -o /tmp/expand/xpn/1/iortest1 -t 512k -b ${file_size} -s 1 -i 1 -d 2 -k -F
mpiexec -l -np 3 \
        -hostfile        /work/machines_mpi \
        -genv XPN_CONF   /shared/config.txt \
        -genv LD_PRELOAD /home/lab/bin/xpn/lib64/xpn_bypass.so:$LD_PRELOAD \
        /home/lab/src/ior/bin/ior -w -W -G ${timestamp} -o /tmp/expand/xpn/2/iortest1 -t 512k -b ${file_size} -s 1 -i 1 -d 2 -k -F

mpiexec -l -np $NL \
        -hostfile        /work/machines_mpi \
        ls -R -als /tmp/expand/data

/home/lab/src/xpn/admire/io-scheduler/expand.sh --hosts ${hostlist_minus} --shareddir "/shared/" --replication_level ${REPLICATION_LEVEL} --verbose shrink
# sleep 2

mpiexec -l -np $NL \
        -hostfile        /work/machines_mpi \
        -genv XPN_CONF   /shared/config.txt \
        ls -R -als /tmp/expand/data

mpiexec -l -np $NL \
        -hostfile        /work/machines_mpi \
        -genv XPN_CONF   /shared/config.txt \
        netstat -tlnp
# export XPN_DEBUG=1
mpiexec -l -np 3 \
        -hostfile        /work/machines_mpi \
        -genv XPN_CONF   /shared/config.txt \
        -genv LD_PRELOAD /home/lab/bin/xpn/lib64/xpn_bypass.so:$LD_PRELOAD \
        /home/lab/src/ior/bin/ior -r -R -G ${timestamp} -o /tmp/expand/xpn/1/iortest1 -t 512k -b ${file_size} -s 1 -i 1 -d 2 -k -F

/home/lab/src/xpn/admire/io-scheduler/expand.sh --hosts ${hostlist} --shareddir "/shared/" --replication_level ${REPLICATION_LEVEL} --verbose expand

mpiexec -l -np $NL \
        -hostfile        /work/machines_mpi \
        -genv XPN_CONF   /shared/config.txt \
        ls -R -als /tmp/expand/data
# sleep 3
# export XPN_DEBUG=1
mpiexec -l -np 3 \
        -hostfile        /work/machines_mpi \
        -genv XPN_CONF   /shared/config.txt \
        -genv LD_PRELOAD /home/lab/bin/xpn/lib64/xpn_bypass.so:$LD_PRELOAD \
        /home/lab/src/ior/bin/ior -r -R -G ${timestamp} -o /tmp/expand/xpn/1/iortest1 -t 512k -b ${file_size} -s 1 -i 1 -d 2 -k -F

/home/lab/src/xpn/admire/io-scheduler/expand.sh --hosts ${hostlist_minus2} --shareddir "/shared/" --replication_level ${REPLICATION_LEVEL} --verbose shrink

mpiexec -l -np $NL \
        -hostfile        /work/machines_mpi \
        -genv XPN_CONF   /shared/config.txt \
        ls -R -als /tmp/expand/data

mpiexec -l -np 3 \
        -hostfile        /work/machines_mpi \
        -genv XPN_CONF   /shared/config.txt \
        -genv LD_PRELOAD /home/lab/bin/xpn/lib64/xpn_bypass.so:$LD_PRELOAD \
        /home/lab/src/ior/bin/ior -r -R -G ${timestamp} -o /tmp/expand/xpn/2/iortest1 -t 512k -b ${file_size} -s 1 -i 1 -d 2 -k -F

/home/lab/src/xpn/admire/io-scheduler/expand.sh --shareddir "/shared/" stop_await

pkill mpiexec
