#!/bin/bash
set -x
set -e


sudo chown lab:lab /shared

sleep 1
SERVER_TYPE=mpi
# SERVER_TYPE=sck
# 1) build configuration file /shared/config.xml
# 2) start mpi_servers in background
NL=$(cat /work/machines_mpi | wc -l)

# export XPN_SCK_PORT=5555 
export XPN_DNS=/shared/dns.txt 
export XPN_CONF=/shared/config.txt
/home/lab/src/xpn/scripts/execute/xpn.sh -e $SERVER_TYPE -w /shared -l /work/machines_mpi -x /tmp -n $NL -p 0 -v start
sleep 5
export XPN_LOCALITY=0
export XPN_THREAD=0
# export XPN_DEBUG=1

# 3) start xpn client
# mpiexec -l -np $NL \
# perf record --call-graph dwarf mpiexec -l -np 1 \
mpiexec -l -np 1 \
        -hostfile        /work/machines_mpi \
        -genv LD_PRELOAD /home/lab/bin/xpn/lib64/xpn_bypass.so:$LD_PRELOAD \
        /home/lab/src/io500/io500 /home/lab/src/io500/config-scc.ini
        # /home/lab/src/ior/bin/ior -w -r -o /tmp/expand/xpn/iortest1 -t 100k -b 100k -s 1000 -i 1 -d 2 
# ls
# hotspot perf.data
# perf report
# cp $(find perf.data) /work/perf.data1
# cp $(find callgrind.out*) /work
# kcachegrind $(find callgrind.out*)
# gprof /home/lab/src/ior/bin/ior gmon.out
# rm callgrind.out*
# export XPN_LOCALITY=0
# export XPN_DEBUG=1
# perf record --call-graph dwarf mpiexec -l -np 1 \
# mpiexec -l -np 1 \
        # -hostfile        /work/machines_mpi \
        # -genv LD_PRELOAD /home/lab/bin/xpn/lib64/xpn_bypass.so:$LD_PRELOAD \
        # /home/lab/src/ior/bin/mdtest -d /tmp/expand/xpn -I 1 -z 1 -b 1 -u -e 100k -w 200k
        # /home/lab/src/ior/bin/mdtest -d /tmp/expand/xpn -I 5 -z 3 -b 4 -u -e 100k -w 200k
# ls
# hotspot perf.data
# perf report
# cp $(find perf.data) /work/perf.data2
# cp /home/lab/bin/xpn/lib64/xpn_bypass.so /work/xpn_bypass.so

# gprof /home/lab/src/ior/bin/mdtest gmon.out
# cp $(find callgrind.out*) /work/callgrind.out2
# kcachegrind $(find callgrind.out*)
# rm callgrind.out*
# ls -rlash /tmp
# netstat -tlnp
# 4) stop mpi_servers
/home/lab/src/xpn/scripts/execute/xpn.sh -e $SERVER_TYPE -w /shared -d /work/machines_mpi stop
sleep 5
netstat -tlnp

pkill mpiexec