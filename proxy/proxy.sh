#!/bin/bash

#mock example use
#terminal 1: nc -l -p 4200
#terminal 2: ./proxy 127.0.0.1 4200
#terminal 3: nc 127.0.0.1 1337 //then type 'a'+enter

if [ $# != 2 ]
then
    printf "[usage]: $0 dest-addr dest-port\n"
    exit 0
fi

#bash variable holding python cmd str
read -r -d '' client_script <<-"EOF"
#client packet parser script
import struct
import sys
import os

client=os.open(sys.argv[1], os.O_RDWR)
packet=os.read(client, 4096)
print(packet.decode())
EOF

#bash variable holding python cmd str
read -r -d '' server_script <<-"EOF"
#server packet parser script
import struct
import sys
import os

EOF

#bash variable holding c src code
read -r -d '' c_code <<-"EOF"
//c program
#include<stdio.h>
#include<stdlib.h>

int main(int argc, char** argv){
    return 0;
}
EOF

#call relative client cmds & scripts
client_parser(){
    for (( ; ; ))
    do
	python3 -c "$client_script" $client
	#tcpflow -c -i lo port 1337
	#timeout 0.1s od -A x -t x1z -v <$client
	#timeout 0.1s hexdump -C -v <$client
	#tcc -run $c_code
    done
}

#call relative server cmds & scripts
server_parser(){
    for (( ; ; ))
    do
	#python3 -c "$server_script" $server
	#tcpflow -c -i lo port 4200
	timeout 0.1s od -A x -t x1z -v <$server
	#timeout 0.1s hexdump -C -v <$server
	#tcc -run $c_code
    done
}

#record all 127.0.0.1 traffic during uptime
packet_capture(){
    touch $tmp/packet_capture.pcap
    tshark -i lo -r $tmp/packet_capture.pcap &
}

#proxy's client facing port
proxy_port="1337"

#make tmp directory and files for named pipes
tmp=`mktemp -d`
loop="$tmp/pipe.loop"
client="$tmp/pipe.client"
server="$tmp/pipe.server"

#make named pipes
mkfifo -m 0600 $loop $client $server

#on exit signal run cmd str
trap 'rm -rf $tmp/pipe.*;mv $tmp/packet_capture.pcap /tmp' EXIT

                 #execute the
client_parser &  #client traffic parser,
server_parser &  #server traffic parser,
packet_capture & #traffic recorder
                 #and, the 
                 #proxy server
nc -l -p $proxy_port <$loop | tee $client | nc $1 $2 | tee $server >$loop
