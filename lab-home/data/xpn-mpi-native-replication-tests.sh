#!/bin/bash
# set -x
usage(){
    echo "run_test <test file> <type> <replication level> <mb>"
}
run_test(){
    if [ "$#" -ne 6 ]; then
        echo "Usage: $0 <test file> <type> <replication level> <mb> <buffer> <n_server_error>"
        exit 1
    fi
    test_file=$1
    type=$2
    replication_level=$3
    mb=$4
    buffer=$5
    n_server_error=$6
    echo -n "Test $1 $2 replication: $3 MB: $4 MB buffer: $5 Num serv error: $6"
    start=$(date +%s.%N)


    sleep 3
    sudo chown lab:lab /shared

    # 1) build configuration file /shared/config.xml
    # 2) start mpi_servers in background
    NL=$(cat /work/machines_mpi | wc -l)
    # Build hostlist
    hostlist=""

    while IFS= read -r line || [ -n "$line" ]; do
        hostlist="$hostlist,$line"
    done < "/work/machines_mpi"

    hostlist="${hostlist:1}"
    # /home/lab/src/xpn/scripts/execute/xpn.sh -w /shared -l /work/machines_mpi -x /tmp/ -n $NL -p $replication_level start \
    /home/lab/src/xpn/admire/io-scheduler/expand.sh --hosts ${hostlist} --shareddir "/shared/" --replication_level ${replication_level} start \
    &> /dev/null

    export XPN_DEBUG=1; 
    # export XPN_THREAD=1; 
    result1=$?
    # 3) start xpn client
    mpiexec -np 1 \
            -hostfile        /work/machines_mpi \
            -genv XPN_DNS    /shared/dns.txt  \
            -genv XPN_CONF   /shared/config.xml \
            -wdir /home/lab/src/xpn/test/performance/xpn-fault-tolerant \
            /home/lab/src/xpn/test/performance/xpn-fault-tolerant/$test_file /xpn/test $mb $buffer $type $n_server_error \
            &> /dev/null    

    result2=$?
    # 4) stop mpi_servers
    /home/lab/src/xpn/admire/io-scheduler/expand.sh --shareddir "/shared/" stop \
    &> /dev/null
    # /home/lab/src/xpn/scripts/execute/xpn.sh -w /shared -d /work/machines_mpi stop \
    result3=$?
    pkill mpiexec


    /home/lab/src/xpn/test/performance/xpn-fault-tolerant/revive-servers.sh \
    &> /dev/null
    # netstat -tlnp
    end=$(date +%s.%N)
    runtime=$(python3 -c "print('%.2f' % (${end} - ${start}))")
    echo -n " Time: $runtime sec"

    if [ "$result1" -eq 0 ] && [ "$result2" -eq 0 ] && [ "$result3" -eq 0 ]; then
        echo -e " \e[32mpassed!\e[0m"
    else
        echo -e " \e[31mfailed!\e[0m Result: start: $result1 run: $result2 stop: $result3"
    fi
}

run_test write-server-read stop 0 1 1 0 
run_test write-server-read stop 0 2.3 1.2 0
run_test write-server-read stop 0 10 2.1 0
run_test server-write-read stop 0 1 1 0 
run_test server-write-read stop 0 2.3 1.2 0
run_test server-write-read stop 0 10 2.1 0

run_test write-server-read stop 1 1 1 1 
run_test write-server-read stop 1 2.3 1.2 1
run_test write-server-read stop 1 10 2.1 1
run_test server-write-read stop 1 1 1 1
run_test server-write-read stop 1 2.3 1.2 1
run_test server-write-read stop 1 10 2.1 1

run_test write-server-read stop 2 1 1 2
run_test write-server-read stop 2 2.3 1.2 2
run_test write-server-read stop 2 10 2.1 2
run_test server-write-read stop 2 1 1 2 
run_test server-write-read stop 2 2.3 1.2 2
run_test server-write-read stop 2 10 2.1 2

# run_test server-write-read stop 2 10 2 3

# run_test write-server-read stop 2 1 1 2
# run_test write-server-read stop 1 2.3 1.2
# run_test write-server-read stop 1 10 2
# run_test write-server-read stop 2 1 1
# run_test write-server-read stop 2 2.3 1.2
# run_test write-server-read stop 2 10 2

# run_test server-write-read stop 2 1 1 2

# run_test write-server-read kill 1 1 1
# run_test write-server-read kill 1 2.3 1.2
# run_test write-server-read kill 1 10 2