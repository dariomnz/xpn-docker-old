#!/bin/bash
set -x

sudo chown lab:lab /shared
# 1) build configuration file /shared/config.xml
# 2) start mpi_servers in background
NL=$(cat /work/machines_mpi | wc -l)
REPLICATION_LEVEL=1

# Build hostlist
hostlist=""

while IFS= read -r line || [ -n "$line" ]; do
    hostlist="$hostlist,$line"
done < "/work/machines_mpi"

hostlist="${hostlist:1}"

hostlist_minus=$(echo "$hostlist" | rev | cut -d',' -f2- | rev)
timestamp=$(date +%s)

# export XPN_DEBUG=1
export XPN_DNS=/shared/dns.txt
export XPN_CONF=/shared/config.xml
sleep 2
/home/lab/src/xpn/admire/io-scheduler/expand.sh --hosts ${hostlist_minus} --shareddir "/shared/" --replication_level ${REPLICATION_LEVEL} start 
cat /shared/dns.txt
sleep 2

mpiexec -l -np 1 \
        -hostfile        /work/machines_mpi \
        -genv XPN_DNS    /shared/dns.txt  \
        -genv XPN_CONF   /shared/config.xml \
        -genv LD_PRELOAD /home/lab/bin/xpn/lib64/xpn_bypass.so:$LD_PRELOAD \
        /home/lab/src/ior/bin/ior -w -W -G ${timestamp} -o /tmp/expand/xpn/iortest1 -t 400k -b 400k -s 500 -i 1 -d 2 -k

mpiexec -l -np $NL \
        -hostfile        /work/machines_mpi \
        -genv XPN_DNS    /shared/dns.txt  \
        -genv XPN_CONF   /shared/config.xml \
        ls -alsh /tmp/expand/data

/home/lab/src/xpn/admire/io-scheduler/expand.sh --hosts ${hostlist} --shareddir "/shared/" --replication_level ${REPLICATION_LEVEL} --verbose expand
sleep 2


mpiexec -l -np 1 \
        -hostfile        /work/machines_mpi \
        -genv XPN_DNS    /shared/dns.txt  \
        -genv XPN_CONF   /shared/config.xml \
        -genv LD_PRELOAD /home/lab/bin/xpn/lib64/xpn_bypass.so:$LD_PRELOAD \
        /home/lab/src/ior/bin/ior -r -R -G ${timestamp} -o /tmp/expand/xpn/iortest1 -t 400k -b 400k -s 500 -i 1 -d 2 -k

/home/lab/src/xpn/admire/io-scheduler/expand.sh --shareddir "/shared/" stop

sleep 3
pkill mpiexec
