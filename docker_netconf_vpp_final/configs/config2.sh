#!/bin/bash
VPPCTL=vppctl
CLISOCK2=/run/vpp/cli.sock


typeset -i cnt=60
until ls -l $CLISOCK2 ; do
       ((cnt=cnt-1)) || exit 1
       sleep 1
done

#$VPPCTL -s $CLISOCK2 create memif socket id 0 filename /run/vpp/memif0.sock
$VPPCTL -s $CLISOCK2 create host-interface name eth0
sleep 1
$VPPCTL -s $CLISOCK2 set interface ip address host-eth0 2000::5/64
sleep 1
$VPPCTL -s $CLISOCK2 set int state host-eth0 up
sleep 1
$VPPCTL -s $CLISOCK2 create host-interface name eth1
sleep 1
$VPPCTL -s $CLISOCK2 set interface ip address host-eth1 2001::4/64
sleep 1
$VPPCTL -s $CLISOCK2 set int state host-eth1 up
sleep 1
$VPPCTL -s $CLISOCK2 create host-interface name eth2
sleep 1
$VPPCTL -s $CLISOCK2 set interface ip address host-eth2 2003::4/64
sleep 1
$VPPCTL -s $CLISOCK2 set int state host-eth2 up

#routing
$VPPCTL -s $CLISOCK2 ip route add 2::2/128 via 2001::5 host-eth1
#sleep 1
$VPPCTL -s $CLISOCK2 ip route add 3::3/128 via 2003::5 host-eth2

$VPPCTL -s $CLISOCK2 trace add af-packet-input 50

#$VPPCTL -s $CLISOCK2 set sr encaps source addr 1::1
#sleep 1
#$VPPCTL -s $CLISOCK2 sr policy add bsid 1::1:999 next 3::3 encap
#sleep 1
#$VPPCTL -s $CLISOCK2 sr steer l3 b001::/64 via bsid 1::1:999
