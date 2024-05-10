#!/bin/bash
set -x

sudo chown lab:lab /shared
# 1) build configuration file /shared/config.xml
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
timestamp=$(date +%s)
file_size=100m
# export XPN_DEBUG=1
export XPN_DNS=/shared/dns.txt
export XPN_CONF=/shared/config.xml
# export XPN_LOCALITY=1
sleep 2
/home/lab/src/xpn/admire/io-scheduler/expand.sh --hosts ${hostlist} --shareddir "/shared/" --replication_level ${REPLICATION_LEVEL} start 
cat /shared/dns.txt
sleep 2


/home/lab/src/xpn/scripts/execute/xpn.sh -s /home/lab/data -x /tmp/expand/data -l /work/machines_mpi -n $NL -p $REPLICATION_LEVEL preload

sleep 5
# export XPN_DEBUG=1
mpiexec -l -np 3 \
        -hostfile        /work/machines_mpi \
        -genv XPN_DNS    /shared/dns.txt  \
        -genv XPN_CONF   /shared/config.xml \
        -genv LD_PRELOAD /home/lab/bin/xpn/lib64/xpn_bypass.so:$LD_PRELOAD \
        /home/lab/src/ior/bin/ior -w -W -G ${timestamp} -o /tmp/expand/xpn/iortest1 -t ${file_size} -b ${file_size} -s 1 -i 1 -d 2 -k -F

mpiexec -l -np $NL \
        -hostfile        /work/machines_mpi \
        -genv XPN_DNS    /shared/dns.txt  \
        -genv XPN_CONF   /shared/config.xml \
        ls -als /tmp/expand/data

/home/lab/src/xpn/admire/io-scheduler/expand.sh --hosts ${hostlist_minus} --shareddir "/shared/" --replication_level ${REPLICATION_LEVEL} --verbose expand_v2
sleep 2

mpiexec -l -np $NL \
        -hostfile        /work/machines_mpi \
        -genv XPN_DNS    /shared/dns.txt  \
        -genv XPN_CONF   /shared/config.xml \
        ls -als /tmp/expand/data

mpiexec -l -np $NL \
        -hostfile        /work/machines_mpi \
        -genv XPN_DNS    /shared/dns.txt  \
        -genv XPN_CONF   /shared/config.xml \
        netstat -tlnp
# export XPN_DEBUG=1
mpiexec -l -np 3 \
        -hostfile        /work/machines_mpi \
        -genv XPN_DNS    /shared/dns.txt  \
        -genv XPN_CONF   /shared/config.xml \
        -genv LD_PRELOAD /home/lab/bin/xpn/lib64/xpn_bypass.so:$LD_PRELOAD \
        /home/lab/src/ior/bin/ior -r -R -G ${timestamp} -o /tmp/expand/xpn/iortest1 -t ${file_size} -b ${file_size} -s 1 -i 1 -d 2 -k -F

/home/lab/src/xpn/admire/io-scheduler/expand.sh --hosts ${hostlist} --shareddir "/shared/" --replication_level ${REPLICATION_LEVEL} --verbose expand_v2

mpiexec -l -np $NL \
        -hostfile        /work/machines_mpi \
        -genv XPN_DNS    /shared/dns.txt  \
        -genv XPN_CONF   /shared/config.xml \
        ls -als /tmp/expand/data

mpiexec -l -np 3 \
        -hostfile        /work/machines_mpi \
        -genv XPN_DNS    /shared/dns.txt  \
        -genv XPN_CONF   /shared/config.xml \
        -genv LD_PRELOAD /home/lab/bin/xpn/lib64/xpn_bypass.so:$LD_PRELOAD \
        /home/lab/src/ior/bin/ior -r -R -G ${timestamp} -o /tmp/expand/xpn/iortest1 -t ${file_size} -b ${file_size} -s 1 -i 1 -d 2 -k -F

/home/lab/src/xpn/admire/io-scheduler/expand.sh --hosts ${hostlist_minus} --shareddir "/shared/" --replication_level ${REPLICATION_LEVEL} --verbose expand_v2

mpiexec -l -np $NL \
        -hostfile        /work/machines_mpi \
        -genv XPN_DNS    /shared/dns.txt  \
        -genv XPN_CONF   /shared/config.xml \
        ls -als /tmp/expand/data

mpiexec -l -np 3 \
        -hostfile        /work/machines_mpi \
        -genv XPN_DNS    /shared/dns.txt  \
        -genv XPN_CONF   /shared/config.xml \
        -genv LD_PRELOAD /home/lab/bin/xpn/lib64/xpn_bypass.so:$LD_PRELOAD \
        /home/lab/src/ior/bin/ior -r -R -G ${timestamp} -o /tmp/expand/xpn/iortest1 -t ${file_size} -b ${file_size} -s 1 -i 1 -d 2 -k -F

/home/lab/src/xpn/admire/io-scheduler/expand.sh --shareddir "/shared/" stop

sleep 3
pkill mpiexec
