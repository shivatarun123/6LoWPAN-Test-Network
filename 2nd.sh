#!/bin/sh
#set -x
# we need some Private Area Network ID
panid="0xbeee"
# number of nodes
numnodes=6
ip netns delete br2
ip netns add br2
ip link add name veth2 type veth peer name vpeer2    
                                                                        
ip -6 addr add fd00:20::1/64 dev vpeer2                                                    
ip li set dev vpeer2 up                                                                       
ip link set dev lo up

ip li set dev veth2 netns br2                                                      
ip netns exec br2 ip link set dev lo up                                                    
ip netns exec br2 ip -6 addr add fd00:20::2/64 dev veth2                           
                                                   

# Direct external traffic to VETH1 through VPEER1 (default gw).                              
#ip netns exec br2 ip -6 route add default via fd00:20::                 
ip netns exec br2 ip link set veth2 up 

# include the kernel module for a fake node, tell it to create six
# nodes
modprobe fakelb numlbs=$numnodes

PHYNUM=`iwpan dev | grep -B 1 wpan3 | sed -ne '1 s/phy#\([0-9]\)/\1/p'`
        iwpan phy${PHYNUM} set netns name br2

        ip netns exec br2 iwpan dev wpan3 set pan_id $panid
        ip netns exec br2 ip link add link wpan3 name lowpan3 type lowpan
        ip netns exec br2 ip link set wpan3 up
        ip netns exec br2 ip link set lowpan3 up
	ip netns exec br2 ip -6 addr add fd00:2::1/64 dev lowpan3
	ip netns exec br2 ip -6 route add default via fd00:20::
	ip netns exec br2 sysctl -w net.ipv6.conf.all.forwarding=1
	
j=0
# initialize all the nodes
for i in $(seq 4 `expr $numnodes - 1`);
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
	ip netns exec wpan${i} ip -6 addr add fd00:2::${j}/64 dev lowpan${i}
	ip netns exec wpan${i} ip -6 route add default via fd00:2:: dev lowpan${i}
	
done
