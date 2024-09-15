#!/bin/bash
set -x

sudo chown lab:lab /shared

sleep 1
SERVER_TYPE=mpi
REPLICATION_LEVEL=0
# SERVER_TYPE=sck
# 1) build configuration file /shared/config.xml
# 2) start mpi_servers in background
NL=$(cat /work/machines_mpi | wc -l)

# export XPN_SCK_PORT=5555 
export XPN_CONF=/shared/config.txt
/home/lab/src/xpn/scripts/execute/xpn.sh -e $SERVER_TYPE -w /shared -l /work/machines_mpi -x /tmp/xpn -n $NL -p $REPLICATION_LEVEL -v start
sleep 5

mpiexec -np $NL \
        -hostfile        /work/machines_mpi \
        mkdir -p /tmp/xpn

mpiexec -np $NL \
        -hostfile        /work/machines_mpi \
        /home/lab/bin/xpn/bin/xpn_preload /work/lab-home /tmp/xpn 524288 $REPLICATION_LEVEL
        # /home/lab/bin/xpn/bin/xpn_preload /work/xpn /tmp/xpn 524288 $REPLICATION_LEVEL

mpiexec -l -np $NL \
        -hostfile        /work/machines_mpi \
        ls -R -lash /tmp/xpn

sleep 1

echo $?
netstat -tlnp
# /home/lab/bin/xpn/bin/xpn-ls-old xpn/
# export XPN_DEBUG=1
gdb -batch -ex run --args /home/lab/bin/xpn/bin/xpn_tree xpn/

# export XPN_DEBUG=1
gdb -batch -ex run -ex bt --args /home/lab/bin/xpn/bin/xpn_get_block_locality xpn/data/xpn-mpi-expand.sh $((0 * 524288))
gdb -batch -ex run --args /home/lab/bin/xpn/bin/xpn_get_block_locality xpn/data/quijote.txt $((1 * 524288))
gdb -batch -ex run --args /home/lab/bin/xpn/bin/xpn_get_block_locality xpn/data/quijote.txt $((2 * 524288))
gdb -batch -ex run --args /home/lab/bin/xpn/bin/xpn_get_block_locality xpn/data/quijote.txt $((3 * 524288))

rm -rf /shared/out_flush
mkdir -p /shared/out_flush
mpiexec -np $NL \
        -hostfile        /work/machines_mpi \
        /home/lab/bin/xpn/bin/xpn_flush /tmp/xpn /shared/out_flush  524288 $REPLICATION_LEVEL

# sleep 1
# netstat -tlnp
# echo $?

# sleep 1

# /home/lab/bin/xpn/bin/xpn_get_block_locality xpn/quijote.txt $((0 * 524288))
# echo $?

# sleep 1

# /home/lab/bin/xpn/bin/xpn_get_block_locality xpn/quijote.txt $((1 * 524288))
# echo $?

# sleep 1

# /home/lab/bin/xpn/bin/xpn_get_block_locality xpn/quijote.txt $((2 * 524288))
# echo $?

sleep 5

# 3) start xpn client
# mpiexec -l -np $NL \
# perf record --call-graph dwarf mpiexec -l -np 1 \
# mpiexec -l -np 1 \
#         -hostfile        /work/machines_mpi \
#         -genv LD_PRELOAD /home/lab/bin/xpn/lib64/xpn_bypass.so:$LD_PRELOAD \
#         /home/lab/src/ior/bin/ior -w -r -o /tmp/expand/xpn/iortest1 -t 100k -b 100k -s 10 -i 1 -d 2 
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
#         -hostfile        /work/machines_mpi \
#         -genv LD_PRELOAD /home/lab/bin/xpn/lib64/xpn_bypass.so:$LD_PRELOAD \
#         /home/lab/src/ior/bin/mdtest -d /tmp/expand/xpn -I 1 -z 1 -b 1 -u -e 100k -w 200k
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
