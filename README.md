# 6LoWPAN-Test-Network

The above codes are for setting up the 6LoWPAN Test network on the Linux MAchine using the Network namespaces.

Network namespaces are used in building the 6LoWPAN network. The setup was done in an Ubuntu 17.04 machine inside a virtual box. The elements that are discussed in the IoT Elements are emulated using the namespaces, thus having the multiple instances of the TCP/IP stack running on the single host.

Namespaces are used to create border routers and motes because, if they we were created in the global namespace, the Linux kernel would be able to apply IPv6 optimizations which may lead to behavior non-compliant with 6LoWPAN and even would be able to hide certain traffic which is not preferable.

The fakelb Linux module is used to create the IoT motes. They use a pre-defined set of radio settings which we modified as per our requirement. The communication is enabled by setting up the same Personal Area Network (PAN) id for all the IoT devices in an IoT site which enables communication between the motes. Border routers have two network interfaces, LoWPAN/WPAN interface to communicate with other IoT devices within the site and virtual Ethernet interface to communicate with the outside world. we use veth-vpeer pair to connect the border router and edge router, forwarding is enabled between the interfaces. Forwarding must be enabled between the edge and the border routers as well to communicate via the internet. Edge router is in the global namespace has three interfaces: two veth devices, each connecting to a border router, and regular Ethernet interface connecting to the Internet.

prerequisite for running the Test Scripts.
Ubuntu 17.04 LTS
WPAN- Tools
