#!/bin/bash
set -x


cd /work/test/libfabric
pwd
ls .



# fi_info

# gcc -o server server.c -I /home/lab/bin/libfabric/include -L/home/lab/bin/libfabric/lib -lfabric
# gcc -o client client.c -I /home/lab/bin/libfabric/include -L/home/lab/bin/libfabric/lib -lfabric
# # gcc -o pingpong pingpong.c -I /home/lab/bin/libfabric/include -L/home/lab/bin/libfabric/lib -lfabric


gcc -c common.c -I /home/lab/bin/libfabric/include -L/home/lab/bin/libfabric/lib -lfabric
gcc -o server server.c common.o -I /home/lab/bin/libfabric/include -L/home/lab/bin/libfabric/lib -lfabric
gcc -o client client.c common.o -I /home/lab/bin/libfabric/include -L/home/lab/bin/libfabric/lib -lfabric
gcc -o example example.c -I /home/lab/bin/libfabric/include -L/home/lab/bin/libfabric/lib -lfabric