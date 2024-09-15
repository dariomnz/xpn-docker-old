#!/bin/bash
set -x

sudo cp -r /work/xpn/src/xpn_client/xpn/xpn_simple/policy/xpn_policy_rw.c /home/lab/src/xpn/src/xpn_client/xpn/xpn_simple/policy
sudo cp -r /work/xpn/test/xpn_metadata /home/lab/src/xpn/test

cd /home/lab/src/xpn
sudo make -j $(nproc)
sudo make install
# sudo ./scripts/compile/build-me-xpn.sh  -m /home/lab/bin/mpich/bin/mpicc  -i /home/lab/bin

cd /home/lab/src/xpn/test/integrity/xpn_metadata
sudo make clean
sudo make -j $(nproc) all


# blocks n_serv replication_level
/home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 10 "3"            "0" 0
/home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 10 "3;4"          "0;5" 0
# /home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 10 "3;4"          "0;5" 1
/home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 25 "3;4;5;6"      "0;5;9;14" 0
# /home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 25 "3;4;5;6"      "0;5;9;14" 1
# /home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 25 "3;4;5;6"      "0;5;9;14" 2
/home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 6  "3;4;6;7"      "0;5;9;15" 0
/home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 10 "3;4;6;7"      "0;5;9;15" 0
/home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 16 "3;4;6;7"      "0;5;9;15" 0
/home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 25 "3;4;6;7"      "0;5;9;15" 0


/home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 10 "3;-2;2"       "0;1;2" 0
/home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 10 "3;-2;2;4"     "0;1;2;5" 0
/home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 15 "3;-2;2;4"     "0;2;5;9" 0
/home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 20 "3;4;-2;3;4"   "0;5;3;9;15" 0
/home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 35 "3;4;-2;3;4"   "0;5;4;13;18" 0
/home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 35 "3;4;-2;3;5"   "0;5;4;13;18" 0
/home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 35 "3;4;-2;3;5;-4;4"   "0;5;4;13;18;2;28" 0
/home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 15 "4;-2;3"   "0;2;7" 0
/home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 16 "4;-2;3;-2;2"   "0;2;7;4;11" 0
/home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 6  "3;-2;2"   "0;1;2" 0
/home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 6  "3;-2;2;-2;1"   "0;1;2;3;5" 0
/home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 25 "3;4;-3;3;4"   "0;5;4;13;15" 0
/home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 8  "4"   "0" 0
/home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 15 "4;-2;3"   "0;2;7" 0
/home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 20 "4;-2;3;-2;2"   "0;2;7;4;11" 0
/home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 20 "4;-2;3;-2;2;-2;1"   "0;2;7;4;11;8;15" 0
/home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 8  "4"   "0" 0
/home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 15 "4;-2;3"   "0;2;7" 0
/home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 20 "4;-2;3;-2;2"   "0;2;7;3;8" 0
/home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 20 "4;-2;3;-2;2;-2;1"   "0;2;7;3;8;5;9" 0
/home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 20 "4"   "0" 0
/home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 20 "4;-2;3"   "0;3;10" 0
/home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 20 "4;-2;3;-2;2"   "0;3;10;4;10" 0
# /home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 15 "4;-2;3;-2"   "0;2;7;4;11" 0
# /home/lab/src/xpn/test/integrity/xpn_metadata/print_blocks 100 20 0

# sudo chown lab:lab /shared

# # 1) build configuration file /shared/config.xml
# # 2) start mpi_servers in background
# NL=$(cat /work/machines_mpi | wc -l)
# /home/lab/src/xpn/scripts/execute/xpn.sh -w /shared -l /work/machines_mpi -x /tmp/ -n $NL -p 2 start

# export XPN_DEBUG=1; 
# export XPN_THREAD=0; 
# export XPN_LOCALITY=1; 
# # 3) start xpn client
# mpiexec -np 1 \
#         -hostfile        /work/machines_mpi \
#         -genv XPN_DNS    /shared/dns.txt  \
#         -genv XPN_CONF   /shared/config.xml \
#         /home/lab/src/xpn/test/performance/xpn-fault-tolerant/rnd-write-read-cmp /xpn/test 1 1

# exit_code=$?
# echo $?
# # 4) stop mpi_servers
# /home/lab/src/xpn/scripts/execute/xpn.sh -w /shared -d /work/machines_mpi stop

# echo "Exit code $exit_code"
# netstat -tlnp