#!/bin/bash
#set -x

DOCKER_PREFIX_NAME=docker
mkdir -p export

while (( "$#" ))
do
	arg_i=$1
	case $arg_i in
	     launch)
         echo "launch"
        ./lab.sh build
        ./lab.sh start 2
        sleep 2
        ./launch.sh exec 1
        ./lab.sh stop
        docker images --format '{{.ID}} {{.Repository}}:{{.Tag}}' | grep -v 'lab' | awk '{print $1}' | xargs docker rmi
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

        # Bash on container...
        echo "Executing /bin/bash on container $CO_ID..."
        CO_NAME=$(docker ps -f name=$DOCKER_PREFIX_NAME -q | head -$CO_ID | tail -1)
        docker exec -it --user lab $CO_NAME bash -c "source .profile; export XPN_DEBUG=1; ./data/xpn-mpi-native-replication.sh"
    ;;

	esac

	shift
done