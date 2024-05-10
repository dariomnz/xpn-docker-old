#!/bin/bash
#set -x

# Usage
# ./launch.sh launch 3 ./data/xpn-mpi-native-replication-tests.sh
# 3 servers, file to exec in server 1 ./data/xpn-mpi-native-replication-tests.sh 

DOCKER_PREFIX_NAME=xpn-docker
mkdir -p export

while (( "$#" ))
do
	arg_i=$1
	case $arg_i in
	     launch)
         shift
         echo "launch"
        ./lab.sh build
        ./lab.sh start $1
        sleep 2
        ./launch.sh exec 1 $2
        ./lab.sh kill
        docker images --format '{{.ID}} {{.Repository}}:{{.Tag}}' | grep 'xpn-docker'| grep -v 'base-xpn-docker' | awk '{print $1}' | xargs docker rmi
    ;;
        exec)
        shift
        echo "exec"
        # Check params
        CO_ID=$1
        CO_NC=$(docker ps -f name=$DOCKER_PREFIX_NAME -q | wc -l)
            if [ $CO_ID -lt 1 ]; then
            echo "ERROR: Container ID $CO_ID out of range (1...$CO_NC)"
                shift
                    continue
                fi
            if [ $CO_ID -gt $CO_NC ]; then
            echo "ERROR: Container ID $CO_ID out of range (1...$CO_NC)"
                shift
                    continue
                fi
        shift
        # Bash on container...
        echo "Executing /bin/bash on container $CO_ID..."
        CO_NAME=$(docker ps -f name=$DOCKER_PREFIX_NAME -q | head -$CO_ID | tail -1)
        docker exec -it --user lab $CO_NAME bash -c \
        "source .profile; 
        $1" \
        # &> launch.out 
    ;;

	esac

	shift
done