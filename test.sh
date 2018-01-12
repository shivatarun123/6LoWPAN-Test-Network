#!/bin/sh
#set -x
# we need some Private Area Network ID
panid="0xbeef"
# number of nodes
numnodes=4
ip netns delete br1
ip netns add br1
ip link add name veth0 type veth peer name vpeer0    
                                                                        
ip -6 addr add fd00:10::1/64 dev vpeer0                                                   
ip li set dev vpeer0 up                                                                       
ip link set dev lo up

ip li set dev veth0 netns br1                                                      
ip netns exec br1 ip link set dev lo up                                                    
ip netns exec br1 ip -6 addr add fd00:10::2/64 dev veth0                           
                                                   
                              
ip netns exec br1 ip -6 route add default via fd00:10::                 
ip netns exec br1 ip link set veth0 up 

# include the kernel module for a fake node, tell it to create six
# nodes
modprobe fakelb numlbs=$numnodes

PHYNUM=`iwpan dev | grep -B 1 wpan0 | sed -ne '1 s/phy#\([0-9]\)/\1/p'`
        iwpan phy${PHYNUM} set netns name br1

        ip netns exec br1 iwpan dev wpan0 set pan_id $panid
        ip netns exec br1 ip link add link wpan0 name lowpan0 type lowpan
        ip netns exec br1 ip link set wpan0 up
        ip netns exec br1 ip link set lowpan0 up
	ip netns exec br1 ip -6 addr add fd00:1::1/64 dev lowpan0

j=0
# initialize all the nodes
for i in $(seq 1 `expr $numnodes - 1`);
do
j=$((j+10))
        ip netns delete wpan${i}
        ip netns add wpan${i}
        PHYNUM=`iwpan dev | grep -B 1 wpan${i} | sed -ne '1 s/phy#\([0-9]\)/\1/p'`
        iwpan phy${PHYNUM} set netns name wpan${i}

        ip netns exec wpan${i} iwpan dev wpan${i} set pan_id $panid
        ip netns exec wpan${i} ip link add link wpan${i} name lowpan${i} type lowpan
        ip netns exec wpan${i} ip link set wpan${i} up
        ip netns exec wpan${i} ip link set lowpan${i} up
	ip netns exec wpan${i} ip -6 addr add fd00:1::${j}/64 dev lowpan${i}
	
done
